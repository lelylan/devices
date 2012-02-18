class PendingProperty
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri
  field :value          # expected new property value
  field :old_value      # previous property value
  field :transitional_values, type: Array, default: []  # values in between the change due to the function
  field :pending_status, type: Boolean, default: true   # pending status of the resource 

  embedded_in :pending

  validates :uri, url: true
  validates :value, presence: true
  validates :old_value, presence: true
  validates :pending_status, inclusion: {in: [true, false]}

  before_save :parse_transitional_values


  def parse_transitional_values
    transitional_values.map!(&:to_s)
  end
end
