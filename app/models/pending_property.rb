class PendingProperty
  include Mongoid::Document
  include Mongoid::Timestamps

  field :property_uri
  field :pending, type: Boolean, default: true 
  field :old_value                                    # previous property value
  field :expected_value                               # expected new property value
  field :received_values, type: Array, default: []    # values received in between from physical

  embedded_in :pending

  validates :property_uri, url: true
  validates :old_value, presence: true
  validates :expected_value, presence: true
end
