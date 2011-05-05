class DeviceProperty
  include Mongoid::Document
  include Mongoid::Timestamps

  field :propery_uri
  field :name
  field :value

  validates :property_uri, url: true
  validates :name, presence: true

  embedded_in :device
end
