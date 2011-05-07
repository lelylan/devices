class PendingProperty
  include Mongoid::Document
  include Mongoid::Timestamps

  field :property_uri
  field :pending_status, type: Boolean, default: true 
  field :value                                        # expected new property value
  field :old_value                                    # previous property value
  field :received_values, type: Array, default: []    # values received in between from physical

  embedded_in :pending

  validates :property_uri, url: true
  validates :value, presence: true
  validates :old_value, presence: true
end
