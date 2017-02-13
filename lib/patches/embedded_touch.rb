# Backport Mongoid 4 :touch option for #embedded_in to Mongoid 3.

if Mongoid::VERSION =~ /\A3\./

module Mongoid
module Relations
  module Embedded
    class In < Relations::One
      class << self
        def valid_options
          [ :autobuild, :cyclic, :polymorphic, :touch ]
        end
      end
    end
  end

  module Macros
    module ClassMethods

      def embedded_in(name, options = {}, &block)
        if ancestors.include?(Mongoid::Versioning)
          raise Errors::VersioningNotOnRoot.new(self)
        end
        meta = characterize(name, Embedded::In, options, &block)
        self.embedded = true
        relate(name, meta)
        builder(name, meta).creator(name, meta)
        touchable(meta)
        add_counter_cache_callbacks(meta) if meta.counter_cached?
        meta
      end
    end
  end
end
end

end
