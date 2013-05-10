class DeviceProperty
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  field :_id, default: ->{ property_id }, type: Moped::BSON::ObjectId
  field :property_id, type: Moped::BSON::ObjectId
  field :value
  field :expected
  field :pending, type: Boolean, default: false
  field :accepted, type: Hash

  index({ property_id: 1, value: 1 }, { background: true })

  embedded_in :device

  validates :property_id, presence: true

  before_save :set_property

  def set_property
    # set always expected to value also when expected is sent
    self.expected = value
    # when is already pending and send a new value the expected value is the old one
    self.expected = expected_was if pending == true and pending_was == true  and device.physical
    # set the old values only when pending is set to true and there is a physical device connectio and there is a physical device connectionn
    self.value = value_was if pending == true and pending_was == false and device.physical
    # set the current values when keep being pending
    self.value = value if pending == true and pending_was == true  and device.physical
    # set always to false when there is no physical device
    self.pending = false if not device.physical
    return true
  end
end
