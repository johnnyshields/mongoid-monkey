
class Address
  include Mongoid::Document
  field :address_type
  field :number, type: Integer
  field :no, type: Integer
  field :h, as: :house, type: Integer
  field :street
  field :city
  field :state
  field :post_code
  field :parent_title
  field :services, type: Array
  field :aliases, as: :a, type: Array
  field :test, type: Array
  field :latlng, type: Array
  field :map, type: Hash
  field :move_in, type: DateTime
  field :end_date, type: Date
  field :s, type: String, as: :suite
  field :name, localize: true

  embedded_in :addressable, polymorphic: true
  embeds_many :locations, validate: false
end
