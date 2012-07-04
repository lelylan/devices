class DevicePhysical
  include Mongoid::Document
  include Mongoid::Timestamps

<<<<<<< HEAD
  field :uri

  attr_accessible :uri

  validates :uri, presence: true, url: true
=======
  field :physical_id
  field :unite_node_uri

  validates :physical_id, presence: true
  validates :unite_node_uri, url: true
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750

  embedded_in :device
end
