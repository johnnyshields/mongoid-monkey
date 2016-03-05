module Mongoid
module Contextual
module Atomic

  def add_to_set_with_mongoid4(*args)
    if args.length == 1 && args.is_a?(Hash)
      query.update_all("$addToSet" => collect_operations(args.first))
    else
      add_to_set_without_mongoid4(*args)
    end
  end
  alias_method_chain :add_to_set, :mongoid4

  def bit_with_mongoid4(*args)
    if args.length == 1 && args.is_a?(Hash)
      query.update_all("$bit" => collect_operations(args.first))
    else
      bit_without_mongoid4(*args)
    end
  end
  alias_method_chain :bit, :mongoid4

  def inc_with_mongoid4(*args)
    if args.length == 1 && args.is_a?(Hash)
      query.update_all("$inc" => collect_operations(args.first))
    else
      inc_without_mongoid4(*args)
    end
  end
  alias_method_chain :inc, :mongoid4

  def pop_with_mongoid4(*args)
    if args.length == 1 && args.is_a?(Hash)
      query.update_all("$pop" => collect_operations(args.first))
    else
      pop_without_mongoid4(*args)
    end
  end
  alias_method_chain :pop, :mongoid4

  def pull_with_mongoid4(*args)
    if args.length == 1 && args.is_a?(Hash)
      query.update_all("$pull" => collect_operations(args.first))
    else
      pull_without_mongoid4(*args)
    end
  end
  alias_method_chain :pull, :mongoid4

  def pull_all_with_mongoid4(*args)
    if args.length == 1 && args.is_a?(Hash)
      query.update_all("$pullAll" => collect_operations(args.first))
    else
      pull_all_without_mongoid4(*args)
    end
  end
  alias_method_chain :pull_all, :mongoid4

  def push_with_mongoid4(*args)
    if args.length == 1 && args.is_a?(Hash)
      query.update_all("$push" => collect_operations(args.first))
    else
      push_without_mongoid4(*args)
    end
  end
  alias_method_chain :push, :mongoid4

  def push_all_with_mongoid4(*args)
    if args.length == 1 && args.is_a?(Hash)
      query.update_all("$pushAll" => collect_operations(args.first))
    else
      push_all_without_mongoid4(*args)
    end
  end
  alias_method_chain :push_all, :mongoid4

  def rename_with_mongoid4(renames)
    if args.length == 1 && args.is_a?(Hash)
      operations = renames.inject({}) do |ops, (old_name, new_name)|
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
    if args.length == 1 && args.is_a?(Hash)
      query.update_all("$set" => collect_operations(args.first))
    else
      set_without_mongoid4(*args)
    end
  end
  alias_method_chain :set, :mongoid4

  private

  def collect_operations(ops)
    ops.inject({}) do |operations, (field, value)|
      operations[database_field_name(field)] = value.mongoize
      operations
    end
  end
end
end
end
