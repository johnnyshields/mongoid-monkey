# Use cursor for aggregation methods in Mongoid 3 in order to support MongoDB 3.6+

if Mongoid::VERSION =~ /\A3\./

  module Moped
    class Collection
      def aggregate(*pipeline)
        pipeline.flatten!
        command = { aggregate: name.to_s, pipeline: pipeline, cursor: {} }
        result = database.session.command(command)['cursor']
        result = result['firstBatch'] if result
        result
      end
    end
  end
end
