class DeviceProperty
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  field :_id, default: ->{ property_id }, type: Moped::BSON::ObjectId
  field :property_id, type: Moped::BSON::ObjectId
  field :value
  field :expected_value
  field :pending, type: Boolean, default: false

  index({ property_id: 1, value: 1 }, { background: true })

  embedded_in :device

  validates :property_id, presence: true

  before_save :set_pending, :auto_set_value

  def set_pending
    self.pending = auto_set_pending if not pending_changed?
    return true
  end

  def auto_set_pending
    return false if device.physical == nil
    return false if expected_value_changed? and value_changed? and value == expected_value
    return true  if expected_value_changed? and value_changed? and value != expected_value
    return true  if pending == true and value_changed? and value != expected_value
    return false if pending == true and value_changed? and value == expected_value
    return true  if expected_value_changed?
    return false
  end

  def auto_set_value
    self.value = expected_value if device.physical == nil and expected_value_changed?
  end
end
