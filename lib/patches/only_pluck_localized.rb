# Backport of https://github.com/mongodb/mongoid/pull/4299 Mongoid 6 to Mongoid 3.

if Mongoid::VERSION =~ /\A3\./

  module Origin
    class Options < Smash

      def store(key, value, localize = true)
        super(key, evolve(value, localize))
      end
      alias :[]= :store

      private

      def evolve(value, localize = true)
        case value
          when Hash
            evolve_hash(value, localize)
          else
            value
        end
      end

      def evolve_hash(value, localize = true)
        value.inject({}) do |hash, (field, _value)|
          name, serializer = storage_pair(field)
          name = normalized_key(name, serializer) if localize
          hash[name] = _value
          hash
        end
      end
    end
  end

  module Origin
    module Optional

      def only(*args)
        args = args.flatten
        option(*args) do |options|
          options.store(
              :fields,
              args.inject({}){ |sub, field| sub.tap { sub[field] = 1 }},
              false
          )
        end
      end

      def without(*args)
        args = args.flatten
        option(*args) do |options|
          options.store(
              :fields,
              args.inject({}){ |sub, field| sub.tap { sub[field] = 0 }},
              false
          )
        end
      end
    end
  end

  module Mongoid
    module Contextual
      class Mongo

        def pluck(field)
          normalized = klass.database_field_name(field)
          query.dup.select(normalized => 1).map{ |doc| doc[normalized.partition('.').first] }.compact
        end
      end
    end
  end
end
