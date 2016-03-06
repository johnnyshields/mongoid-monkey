
class User
  include Mongoid::Document
  field :name
  index name: 1
end
