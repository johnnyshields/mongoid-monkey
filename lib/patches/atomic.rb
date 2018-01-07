# Backport Mongoid 4 hash-based atomic method syntax to Mongoid 3.

if Mongoid::VERSION =~ /\A3\./

module Mongoid
module Contextual
module Atomic

  def add_to_set_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      query.update_all("$addToSet" => collect_operations(args.first))
    else
      add_to_set_without_mongoid4(*args)
    end
  end
  alias_method_chain :add_to_set, :mongoid4

  def bit_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      query.update_all("$bit" => collect_operations(args.first))
    else
      bit_without_mongoid4(*args)
    end
  end
  alias_method_chain :bit, :mongoid4

  def inc_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      query.update_all("$inc" => collect_operations(args.first))
    else
      inc_without_mongoid4(*args)
    end
  end
  alias_method_chain :inc, :mongoid4

  def pop_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      query.update_all("$pop" => collect_operations(args.first))
    else
      pop_without_mongoid4(*args)
    end
  end
  alias_method_chain :pop, :mongoid4

  def pull_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      query.update_all("$pull" => collect_operations(args.first))
    else
      pull_without_mongoid4(*args)
    end
  end
  alias_method_chain :pull, :mongoid4

  def pull_all_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      query.update_all("$pullAll" => collect_operations(args.first))
    else
      pull_all_without_mongoid4(*args)
    end
  end
  alias_method_chain :pull_all, :mongoid4

  def push_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      query.update_all("$push" => collect_operations(args.first))
    else
      push_without_mongoid4(*args)
    end
  end
  alias_method_chain :push, :mongoid4

  # Uses $push + $each rather than $pushAll
  def push_all(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      query.update_all("$push" => collect_operations(args.first, true))
    else
      query.update_all("$push" => { database_field_name(args[0]) => { "$each" => Array.wrap(args[1]) } })
    end
  end

  def rename_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      operations = args.first.inject({}) do |ops, (old_name, new_name)|
        ops[old_name] = new_name.to_s
        ops
      end
      query.update_all("$rename" => collect_operations(operations))
    else
      rename_without_mongoid4(*args)
    end
  end
  alias_method_chain :rename, :mongoid4

  def set_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      query.update_all("$set" => collect_operations(args.first))
    else
      set_without_mongoid4(*args)
    end
  end
  alias_method_chain :set, :mongoid4

  private

  def collect_operations(ops, use_each = false)
    ops.inject({}) do |operations, (field, value)|
      operations[database_field_name(field)] = use_each ? { '$each' => Array.wrap(value.mongoize) } : value.mongoize
      operations
    end
  end
end
end
end

module Mongoid
module Persistence
module Atomic

  # Replace usage of $pushAll with $push + $each
  class PushAll
    def persist
      append_with("$push")
    end

    def operation(modifier)
      { modifier => { path => { "$each" => Array.wrap(value) } } }
    end
  end

  def add_to_set_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      adds = args.first
      prepare_atomic_operation do |ops|
        process_atomic_operations(adds) do |field, value|
          existing = send(field) || (attributes[field] ||= [])
          values = [ value ].flatten(1)
          values.each do |val|
            existing.push(val) unless existing.include?(val)
          end
          ops[atomic_attribute_name(field)] = { "$each" => values }
        end
        { "$addToSet" => ops }
      end
    else
      add_to_set_without_mongoid4(*args)
    end
  end
  alias_method_chain :add_to_set, :mongoid4

  def bit_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      operations = args.first
      prepare_atomic_operation do |ops|
        process_atomic_operations(operations) do |field, values|
          value = attributes[field]
          values.each do |op, val|
            value = value & val if op.to_s == "and"
            value = value | val if op.to_s == "or"
          end
          attributes[field] = value
          ops[atomic_attribute_name(field)] = values
        end
        { "$bit" => ops }
      end
    else
      bit_without_mongoid4(*args)
    end
  end
  alias_method_chain :bit, :mongoid4

  def inc_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      increments = args.first
      prepare_atomic_operation do |ops|
        process_atomic_operations(increments) do |field, value|
          increment = value.__to_inc__
          current = attributes[field]
          attributes[field] = (current || 0) + increment
          ops[atomic_attribute_name(field)] = increment
        end
        { "$inc" => ops }
      end
    else
      inc_without_mongoid4(*args)
    end
  end
  alias_method_chain :inc, :mongoid4

  def pop_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      pops = args.first
      prepare_atomic_operation do |ops|
        process_atomic_operations(pops) do |field, value|
          values = send(field)
          value > 0 ? values.pop : values.shift
          ops[atomic_attribute_name(field)] = value
        end
        { "$pop" => ops }
      end
    else
      pop_without_mongoid4(*args)
    end
  end
  alias_method_chain :pop, :mongoid4

  def pull_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      pulls = args.first
      prepare_atomic_operation do |ops|
        process_atomic_operations(pulls) do |field, value|
          (send(field) || []).delete(value)
          ops[atomic_attribute_name(field)] = value
        end
        { "$pull" => ops }
      end
    else
      pull_without_mongoid4(*args)
    end
  end
  alias_method_chain :pull, :mongoid4

  def pull_all_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      pulls = args.first
      prepare_atomic_operation do |ops|
        process_atomic_operations(pulls) do |field, value|
          existing = send(field) || []
          value.each{ |val| existing.delete(val) }
          ops[atomic_attribute_name(field)] = value
        end
        { "$pullAll" => ops }
      end
    else
      pull_all_without_mongoid4(*args)
    end
  end
  alias_method_chain :pull_all, :mongoid4

  def push_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      pushes = args.first
      prepare_atomic_operation do |ops|
        process_atomic_operations(pushes) do |field, value|
          existing = send(field) || (attributes[field] ||= [])
          values = [ value ].flatten(1)
          values.each{ |val| existing.push(val) }
          ops[atomic_attribute_name(field)] = { "$each" => values }
        end
        { "$push" => ops }
      end
    else
      push_without_mongoid4(*args)
    end
  end
  alias_method_chain :push, :mongoid4

  def rename_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      renames = args.first
      prepare_atomic_operation do |ops|
        process_atomic_operations(renames) do |old_field, new_field|
          new_name = new_field.to_s
          attributes[new_name] = attributes.delete(old_field)
          ops[atomic_attribute_name(old_field)] = atomic_attribute_name(new_name)
        end
        { "$rename" => ops }
      end
    else
      rename_without_mongoid4(*args)
    end
  end
  alias_method_chain :rename, :mongoid4

  def set_with_mongoid4(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      setters = args.first
      prepare_atomic_operation do |ops|
        process_atomic_operations(setters) do |field, value|
          process_attribute(field.to_s, value)
          ops[atomic_attribute_name(field)] = attributes[field]
        end
        { "$set" => ops }
      end
    else
      set_without_mongoid4(*args)
    end
  end
  alias_method_chain :set, :mongoid4

  # unset params are consistent, however it returns self in Mongoid 4
  # def unset_with_mongoid4(*args)
  #   unset_without_mongoid4(*args)
  #   self
  # end
  # alias_method_chain :unset, :mongoid4

  private

  def executing_atomically?
    !@atomic_updates_to_execute.nil?
  end

  def post_process_persist(result, options = {})
    post_persist unless result == false
    errors.clear unless performing_validations?(options)
    true
  end

  def prepare_atomic_operation
    operations = yield({})
    persist_or_delay_atomic_operation(operations)
    self
  end

  def process_atomic_operations(operations)
    operations.each do |field, value|
      unless attribute_writable?(field)
        raise Errors::ReadonlyAttribute.new(field, value)
      end
      normalized = database_field_name(field)
      yield(normalized, value)
      remove_change(normalized)
    end
  end

  def persist_or_delay_atomic_operation(operation)
    if executing_atomically?
      operation.each do |(name, hash)|
        @atomic_updates_to_execute[name] ||= {}
        @atomic_updates_to_execute[name].merge!(hash)
      end
    else
      persist_atomic_operations(operation)
    end
  end

  def persist_atomic_operations(operations)
    if persisted?
      selector = atomic_selector
      _root.collection.find(selector).update(operations)
    end
  end
end
end
end

end
