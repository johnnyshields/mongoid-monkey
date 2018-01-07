# Replace usage of $pushAll with $push + $each for MongoDB 3.6 support.
# Note that some of this is done in the `atomic.rb` patch as well.

if Mongoid::VERSION =~ /\A3\./

module Mongoid
module Relations
module Embedded
module Batchable
  def batch_insert(docs)
    execute_batch_insert(docs, "$push", true)
  end

  def execute_batch_insert(docs, operation, use_each = false)
    self.inserts_valid = true
    inserts = pre_process_batch_insert(docs)
    if insertable?
      collection.find(selector).update(
          positionally(selector, operation => { path => use_each ? { '$each' => Array.wrap(inserts) } : inserts })
      )
      post_process_batch_insert(docs)
    end
    inserts
  end
end
end
end
end

module Mongoid
module Atomic
class Modifiers < Hash
  def push(modifications)
    modifications.each_pair do |field, value|
      push_fields[field] = field
      mods = push_conflict?(field) ? conflicting_pushes : pushes
      add_each_operation(mods, field, Array.wrap(value))
    end
  end

  def add_each_operation(mods, field, value)
    if mods.has_key?(field)
      value.each do |val|
        mods[field]["$each"].push(val)
      end
    else
      mods[field] = { "$each" => value }
    end
  end

  def conflicting_pushes
    conflicts["$push"] ||= {}
  end

  def pushes
    self["$push"] ||= {}
  end
end
end
end

end
