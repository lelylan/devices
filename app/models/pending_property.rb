class PendingProperty
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri
  field :value                                        # expected new property value
  field :old_value                                    # previous property value
  field :pending_status, type: Boolean, default: true # pending status of the resource 

  embedded_in :pending

  validates :uri, url: true
  validates :value, presence: true
  validates :old_value, presence: true
end
