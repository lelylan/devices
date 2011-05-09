class Consumption
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :uri
  field :created_from
  field :type, default: 'istantaneus'
  field :energy, type: Float, default: '0.0'
  field :unit, default: 'kwh'
  field :occur_at, type: Time
  field :end_at, type: Time
  field :duration, type: Float, default: '0.0'

  attr_accessible :type, :energy, :unit

  validates :uri, presence: true, url: true
  validates :created_from, presence: true, url: true
  validates :type, inclusion: { in: %w(istantaneus durational) }
  validates :energy, presence: true
  validates :unite, inclusion: { in %w(kwh) }
  validates :occur_at, presence: true
  
end
