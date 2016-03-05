# Get collection_names via for MongoDB 3.0+ listCollections command.
# Required to use Moped (Mongoid 3/4) with WiredTiger.

module Moped
  class Database

    def collection_names
      namespaces = Collection.new(self, "$cmd").find(listCollections: 1, name: { "$not" => /#{name}\.system\.|\$/ }).first
      namespaces["cursor"]["firstBatch"].map do |doc|
        doc["name"]
      end
    end
  end
end
