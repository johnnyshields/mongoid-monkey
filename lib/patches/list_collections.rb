# Get collection_names via for MongoDB 3.0+ listCollections command.
# Required to use Moped (Mongoid 3/4) with WiredTiger.

module Moped
  class Database

    def collection_names
      namespaces = Collection.new(self, "$cmd").find(listCollections: 1, filter: { name: { "$not" => /system\.|\$/ } }).first
      namespaces["cursor"]["firstBatch"].map do |doc|
        doc["name"]
      end
    end
  end
end
