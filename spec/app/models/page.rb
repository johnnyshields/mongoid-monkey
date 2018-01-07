class Page
  include Mongoid::Document
  embedded_in :quiz
  embeds_many :page_questions
  embedded_in :book, touch: true
  field :content, :type => String
end
