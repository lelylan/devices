class HistoryProperty
  include Mongoid::Document
  include Mongoid::Timestamps

  field :property_uri
  field :value

  embedded_in :histoy
  
  validates :property_uri, presence: true, url: true
  validates :value, presence:true
end
