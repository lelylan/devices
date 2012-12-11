class DeviceProperty
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  field :_id, default: ->{ property_id }, type: Moped::BSON::ObjectId
  field :property_id, type: Moped::BSON::ObjectId
  field :value
  field :physical_value
  field :pending, type: Boolean, default: false

  index({ property_id: 1, value: 1 }, { background: true })

  embedded_in :device

  validates :property_id, presence: true

  before_save :set_pending

  def set_pending
    self.pending = auto_pending if not pending_changed?
    return true
  end

  def auto_pending
    return false if device.physical == nil
    return false if value_changed? and physical_value_changed? and value == physical_value
    return true  if pending == false and value_changed?
    return true  if pending == true  and physical_value_changed? and value != physical_value
    return false if pending == true  and physical_value_changed? and value == physical_value
    return false
  end
end
