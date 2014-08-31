class DeviceProperty
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  field :_id, default: ->{ property_id }, type: Moped::BSON::ObjectId
  field :property_id, type: Moped::BSON::ObjectId
  field :value
  field :expected
  field :pending, type: Boolean, default: false
  field :accepted, type: Array, default: []

  index({ property_id: 1, value: 1 }, { background: true })

  embedded_in :device

  validates :property_id, presence: true

  before_save :set_property

  def set_property
    self.expected = value    if value_changed?    and not expected_changed? and pending == false
    self.expected = value    if value_changed?    and not device.physical?
    self.value    = expected if expected_changed? and not device.physical?
    self.pending  = false    if not device.physical?

    return true
  end

  def physical?
    !!(device.physical and device.physical['uri'])
  end
end
