class DevicePhysical
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri

  validates :uri, presence: true, uri: true

  embedded_in :device
end
