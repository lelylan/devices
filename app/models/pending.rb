class Pending
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri
  field :created_from
  field :device_uri
  field :function_uri
  field :expected_time        # time to complete the funciton (in seconds)
  
  embeds_many :pending_properties
  
  validates :uri, url: true
  validates :created_from, url: true
  validates :device_uri, url: true
  validates :function_uri, url: true

end
