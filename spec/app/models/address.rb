
class Address
  include Mongoid::Document
  field :street
  field :name, localize: true
  embedded_in :addressable, polymorphic: true
end
