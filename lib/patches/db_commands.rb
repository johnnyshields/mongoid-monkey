# Use MongoDB 3.0+ syntax for a few database-level commands.
# Required to use Moped (Mongoid 3/4) with WiredTiger:
# - listCollections
# - listIndexes
# - createIndexes

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

    def [](key)
      result = database.command(listIndexes: collection_name)
      result["cursor"]["firstBatch"].detect do |index|
        (index['name'] == key) || (index['key'] == normalize_keys(key))
      end
    end

    def create(key, options = {})
      spec = options.merge(ns: namespace, key: key)
      spec[:name] ||= key.to_a.join("_")
      database.command(createIndexes: collection_name, indexes: [spec])
    end

    protected

    def normalize_keys(spec)
      return false if spec.is_a?(String)
      spec.reduce({}) do |transformed, (key, value)|
        transformed[key.to_s] = value
        transformed
      end
    end
  end
end
