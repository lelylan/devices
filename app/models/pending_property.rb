class PendingProperty
  include Mongoid::Document
  include Mongoid::Timestamps

  field :device_uri
  field :pending, type: Boolean, default: true
  field :old_value
  field :expected_value
  field :received_values, type: Array, default: []

  validates :device_uri, url: true
  validates :old_value, presence: true
  validates :expected_value, presence: true
end
