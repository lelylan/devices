class DeviceProperty
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri
  field :name
  field :value
  field :pending, type: Boolean, default: false

  validates :uri, url: true
  validates :name, presence: true
  validates :pending, inclusion: {in: [true, false]}

  embedded_in :device
end
