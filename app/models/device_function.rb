class DeviceFunction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :function_uri
  field :uri
  field :name

  validates :function_uri, url: true
  validates :uri, url: true
  validates :name, presence: true

  embedded_in :device
end
