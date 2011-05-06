class DevicePhysical
  include Mongoid::Document
  include Mongoid::Timestamps

  field :physical_id
  field :unite_node_uri

  validates :physical_id, presence: true
  validates :unite_node_uri, url: true

  embedded_in :device
end
