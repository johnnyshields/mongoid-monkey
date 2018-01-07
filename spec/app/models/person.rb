
class Person
  include Mongoid::Document

  index age: 1
  index addresses: 1
  index dob: 1
  index name: 1
  index title: 1
  index({ ssn: 1 }, { unique: true })
  field :username, default: -> { "arthurnn#{rand(0..10)}" }
  field :title
  field :terms, type: Boolean
  field :pets, type: Boolean, default: false
  field :age, type: Integer, default: "100"
  field :dob, type: Date
  field :employer_id
  field :lunch_time, type: Time
  field :aliases, type: Array
  field :map, type: Hash
  field :map_with_default, type: Hash, default: {}
  field :score, type: Integer
  field :blood_alcohol_content, type: Float, default: ->{ 0.0 }
  field :last_drink_taken_at, type: Date, default: ->{ 1.day.ago.in_time_zone("Alaska") }
  field :ssn
  field :owner_id, type: Integer
  field :security_code
  field :reading, type: Object
  field :pattern, type: Regexp
  field :override_me, type: Integer
  field :at, as: :aliased_timestamp, type: Time
  field :t, as: :test, type: String
  field :i, as: :inte, type: Integer
  field :a, as: :array, type: Array
  field :desc, localize: true
  field :test_array, type: Array
  field :overridden_setter, type: String
  field :arrays, type: Array
  field :range, type: Range

  embeds_many :addresses, as: :addressable, validate: false
  embeds_many :videos, order: [[ :title, :asc ]], validate: false
  embeds_many :appointments, validate: false
  embeds_many :symptoms, validate: false
  embeds_many :phone_numbers, class_name: "Phone", validate: false
  embeds_many :phones, store_as: :mobile_phones, validate: false
  embeds_one :name, as: :namable, validate: false do
    def extension
      "Testing"
    end
    def dawkins?
      first_name == "Richard" && last_name == "Dawkins"
    end
  end
end
