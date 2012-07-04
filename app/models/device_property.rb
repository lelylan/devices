class DeviceProperty
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri
<<<<<<< HEAD
  field :value          # property value
  field :pending        # pending property value

  attr_accessible :uri, :value

  validates :uri, url: true
=======
  field :name
  field :value
  field :pending, type: Boolean, default: false

  validates :uri, url: true
  validates :name, presence: true
  validates :pending, inclusion: {in: [true, false]}
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750

  embedded_in :device
end
