class DeviceFunction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri
  field :name

  validates :uri, url: true
  validates :name, presence: true

  embedded_in :device
end
