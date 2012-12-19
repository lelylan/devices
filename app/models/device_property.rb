class DeviceProperty
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  field :_id, default: ->{ property_id }, type: Moped::BSON::ObjectId
  field :property_id, type: Moped::BSON::ObjectId
  field :value
  field :expected
  field :pending, type: Boolean, default: false
  field :suggested, type: Hash, default: {}

  index({ property_id: 1, value: 1 }, { background: true })

  embedded_in :device

  validates :property_id, presence: true

  before_save :set_pending, :set_value

  def set_value
    self.value = expected if device.physical == nil and expected_changed?
  end

  def set_pending
    self.pending = auto_pending if not pending_changed?
    return true
  end

  def auto_pending
    return false if device.physical == nil
    return false if expected_changed? and value_changed? and value == expected
    return true  if expected_changed? and value_changed? and value != expected
    return true  if pending == true and value_changed? and value != expected
    return false if pending == true and value_changed? and value == expected
    return true  if expected_changed?
    return false
  end
end
