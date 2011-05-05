class DeviceProperty
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri
  field :name
  field :value

  validates :uri, url: true
  validates :name, presence: true

  embedded_in :device
end
