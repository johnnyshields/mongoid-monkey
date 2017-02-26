class Page
  include Mongoid::Document

  embedded_in :book, touch: true
  field :content, :type => String
end
