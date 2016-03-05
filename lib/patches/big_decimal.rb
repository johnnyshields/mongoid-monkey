# Fixes inconsistent behavior of BigDecimal. This can be removed after
# https://github.com/mongodb/mongoid/pull/4164 is merged, planned for Mongoid 6.

module MongoidMonkey
  module Mongoid
    module Extensions
      module BigDecimal

        def numeric?
          true
        end

        module ClassMethods

          def demongoize(object)
            object && object.numeric? ? ::BigDecimal.new(object.to_s) : nil
          end

          def mongoize(object)
            object && object.numeric? ? object.to_s : nil
          end
        end
      end

      module String

        def numeric?
          true if Float(self) rescue (self =~ /^NaN|\-?Infinity$/)
        end
      end
    end
  end
end

::BigDecimal.__send__(:include, MongoidMonkey::Mongoid::Extensions::BigDecimal)
::BigDecimal.extend(MongoidMonkey::Mongoid::Extensions::BigDecimal::ClassMethods)

::String.__send__(:include, MongoidMonkey::Mongoid::Extensions::String)
