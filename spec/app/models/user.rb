
class User
  include Mongoid::Document
  field :name
  index name: 1
  has_one :role, validate: false
end
