# Use MongoDB 3.0+ syntax for a few database-level commands.
# Required to use Moped (Mongoid 3/4) with WiredTiger:
# - listCollections
# - listIndexes
# - createIndexes

if defined?(Moped)

  module Moped
    class Database

      def collection_names
        namespaces = command(listCollections: 1, filter: { name: { "$not" => /system\.|\$/ } })
        namespaces["cursor"]["firstBatch"].map do |doc|
          doc["name"]
        end
      end
    end
  end

  module Moped
    class Indexes

      OPTIONS = {
          :background => :background,
          :bits => :bits,
          :bucket_size => :bucketSize,
          :default_language => :default_language,
          :expire_after => :expireAfterSeconds,
          :expire_after_seconds => :expireAfterSeconds,
          :key => :key,
          :language_override => :language_override,
          :max => :max,
          :min => :min,
          :name => :name,
          :partial_filter_expression => :partialFilterExpression,
          :sparse => :sparse,
          :sphere_version => :'2dsphereIndexVersion',
          :storage_engine => :storageEngine,
          :text_version => :textIndexVersion,
          :unique => :unique,
          :version => :v,
          :weights => :weights,
          :collation => :collation
      }.freeze

      def [](key)
        list_indexes_command.detect do |index|
          (index['name'] == key) || (index['key'] == normalize_keys(key))
        end
      end

      def create(key, options = {})
        spec = options.reduce({}) do |transformed, (key, value)|
          transformed[OPTIONS[key.to_sym]] = value if OPTIONS[key.to_sym]
          transformed
        end
        spec = spec.merge(ns: namespace, key: key)
        spec[:name] ||= key.to_a.join("_")
        database.command(createIndexes: collection_name, indexes: [spec])
      end

      def each(&block)
        list_indexes_command.each(&block)
      end

      protected

      def list_indexes_command
        database.command(listIndexes: collection_name)["cursor"]["firstBatch"]
      end

      def normalize_keys(spec)
        return false if spec.is_a?(String)
        spec.reduce({}) do |transformed, (key, value)|
          transformed[key.to_s] = value
          transformed
        end
      end
    end
  end
end

if Mongoid::VERSION =~ /\A3\./ && defined?(Rails::Mongoid)

  module Rails::Mongoid

    def remove_indexes(*globs)
      models(*globs).each do |model|
        next if model.embedded?
        begin
          indexes = model.collection.indexes.map{ |doc| doc["name"] }
          indexes.delete_one("_id_")
          model.remove_indexes
        rescue Moped::Errors::OperationFailure
          next
        end
        logger.info("MONGOID: Removing indexes on: #{model} for: #{indexes.join(', ')}.")
        model
      end.compact
    end
  end
end

if Mongoid::VERSION =~ /\A4\./

  module Mongoid::Tasks::Database

    def undefined_indexes(models = ::Mongoid.models)
      undefined_by_model = {}

      models.each do |model|
        unless model.embedded?
          begin
            model.collection.indexes.each do |index|
                # ignore default index
                unless index['name'] == '_id_'
                  key = index['key'].symbolize_keys
                  spec = model.index_specification(key)
                  unless spec
                    # index not specified
                    undefined_by_model[model] ||= []
                    undefined_by_model[model] << index
                  end
                end
            end
          rescue Moped::Errors::OperationFailure; end
        end
      end

      undefined_by_model
    end

    def remove_indexes(models = ::Mongoid.models)
      models.each do |model|
        next if model.embedded?
        begin
          indexes = model.collection.indexes.map{ |doc| doc["name"] }
          indexes.delete_one("_id_")
          model.remove_indexes
        rescue Moped::Errors::OperationFailure
          next
        end
        logger.info("MONGOID: Removing indexes on: #{model} for: #{indexes.join(', ')}.")
        model
      end.compact
    end
  end
end
