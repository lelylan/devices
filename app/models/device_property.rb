class DeviceProperty
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  field :property_id, type: Moped::BSON::ObjectId
  field :value
  field :pending_value, default: ''
  field :_id, default: ->{ property_id }

  embedded_in :device

  validates :property_id, presence: true
end
