class HistoryProperty
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri
  field :value

  embedded_in :histoy

  validates :uri, presence: true, url: true
  validates :value, presence:true
end
