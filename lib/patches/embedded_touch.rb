# Backport support #embedded_in :touch option from Mongoid 4 to Mongoid 3.
# Also support touch callback on update, and fix infinite loop issue.

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

    module Touchable
      module ClassMethods

        def touchable(metadata)
          if metadata.touchable?
            name = metadata.name
            method_name = define_relation_touch_method(name)
            after_save method_name
            after_destroy method_name
            after_touch method_name
          end
          self
        end
      end
    end
  end

  module Callbacks
    def cascadable_children(kind, children = Set.new)
      embedded_relations.each_pair do |name, metadata|
        next unless metadata.cascading_callbacks?
        without_autobuild do
          delayed_pulls = delayed_atomic_pulls[name]
          delayed_unsets = delayed_atomic_unsets[name]
          children.merge(delayed_pulls) if delayed_pulls
          children.merge(delayed_unsets) if delayed_unsets
          relation = send(name)
          Array.wrap(relation).each do |child|
            next if children.include?(child)
            children.add(child) if cascadable_child?(kind, child, metadata)
            child.send(:cascadable_children, kind, children)
          end
        end
      end
      children.to_a
    end

    def cascadable_child?(kind, child, metadata)
      return false if kind == :initialize || kind == :find || kind == :touch
      return false if kind == :validate && metadata.validate?
      child.callback_executable?(kind) ? child.in_callback_state?(kind) : false
    end
  end
end

end

if Mongoid::VERSION =~ /\A[45]\./

module Mongoid

  module Interceptable
    def cascadable_child?(kind, child, metadata)
      return false if kind == :initialize || kind == :find || kind == :touch
      return false if kind == :validate && metadata.validate?
      child.callback_executable?(kind) ? child.in_callback_state?(kind) : false
    end
  end
end

end
