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
    # if pending does not change set it to false by default
    # ...

    # set always to value unless you do not set the desired value
    self.expected = value if not expected_changed?

    # set the old values only when pending is set to true and there is a physical device connectio and there is a physical device connectionn
    self.value = value_was if pending == true and device.physical

    # set always to false when there is no physical device
    self.pending = false if not device.physical

    return true
  end
end
