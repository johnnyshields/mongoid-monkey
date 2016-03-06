# Instrument Moped 1.x same as Moped 2.x.
# Useful for integration with third-party services.

if defined?(Moped) && Moped::VERSION =~ /\A1\./

  module Moped
    module Instrumentable
      class Noop

        class << self

          # Do not instrument anything.
          def instrument(name, payload = {})
            yield payload if block_given?
          end
        end
      end
    end
  end

  module Moped
    module Instrumentable

      TOPIC = "query.moped"

      def instrumenter
        @instrumenter ||= Moped::Instrumentable::Noop
      end

      def instrument(name, payload = {}, &block)
        instrumenter.instrument(name, payload, &block)
      end
    end
  end

  module Moped
    class Node
      include Moped::Instrumentable

      def logging_with_instrument(operations, &block)
        instrument(TOPIC, prefix: "  MOPED: #{resolved_address}", ops: operations) do
          logging_without_instrument(operations, &block)
        end
      end
      alias_method_chain :logging, :instrument
    end
  end
end
