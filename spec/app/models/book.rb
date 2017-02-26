class Book
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :pages, cascade_callbacks: true
end
