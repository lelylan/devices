class DevicePhysical
  include Mongoid::Document
  include Mongoid::Timestamps

  field :physical_id
  field :unite_node_uri
  field :unite_node_name

  embedded_in :device
end
