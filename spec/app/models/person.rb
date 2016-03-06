
class Person
  include Mongoid::Document

  index age: 1
  index addresses: 1
  index dob: 1
  index name: 1
  index title: 1
  index({ ssn: 1 }, { unique: true })
end
