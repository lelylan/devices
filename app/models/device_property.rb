class DeviceProperty
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri
  field :value          # property value
  field :pending        # pending property value

  attr_accessible :uri, :value

  validates :uri, url: true

  embedded_in :device
end
