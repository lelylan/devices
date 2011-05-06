class DeviceProperty
  include Mongoid::Document
  include Mongoid::Timestamps

  field :property_uri
  field :name
  field :value

  validates :property_uri, url: true
  validates :name, presence: true

  embedded_in :device
end
