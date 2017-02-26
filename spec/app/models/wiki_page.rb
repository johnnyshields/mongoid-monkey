class WikiPage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String

  embeds_many :edits, validate: false
end
