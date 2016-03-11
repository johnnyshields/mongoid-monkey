class Name
  include Mongoid::Document

  field :first_name, type: String
  field :last_name, type: String
  field :parent_title, type: String
  field :middle, type: String

  embedded_in :namable, polymorphic: true

  def set_parent=(set = false)
    self.parent_title = namable.title if set
  end
end
