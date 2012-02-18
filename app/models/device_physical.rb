class DevicePhysical
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri
  attr_accessible :uri
  validates :uri, presence: true, url: true

  embedded_in :device
end
