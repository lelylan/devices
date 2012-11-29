class Consumption
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  field :resource_owner_id, type: Moped::BSON::ObjectId
  field :device_id, type: Moped::BSON::ObjectId
  field :value
  field :type, default: 'instantaneous'
  field :unit, default: 'kwh'
  field :occur_at, type: Time, default: lambda {Time.now}
  field :end_at,   type: Time
  field :duration, type: Float

  index({ resource_owner_id: 1 }, { background: true })
  index({ device_id: 1 }, { background: true })
  index({ type: 1 }, { background: true })
  index({ unit: 1 }, { background: true })
  index({ occur_at: 1 }, { background: true })

  attr_accessor  :device
  attr_protected :resource_owner_id, :device_id

  validates :resource_owner_id, presence: true
  validates :device,    presence: true, uri: true, on: :create
  validates :type,      inclusion: { in: %w(instantaneous durational) }
  validates :value,     presence: true
  validates :occur_at,  presence: true
  validates :end_at,    presence: true, if: :durational?
  validates :duration,  presence: true, if: :durational?

  before_validation :normalize_timings
  before_create :set_device_id

  # TODO: seems a bug, as the serializer should be automatically found
  def active_model_serializer; ConsumptionSerializer; end

  def normalize_timings
    if durational?
      self.end_at   = calculate_end_at   if (occur_at and duration and end_at.nil?)
      self.occur_at = calculate_occur_at if (end_at and duration and occur_at.nil?)
      self.duration = calculate_duration if (occur_at and end_at and duration.nil?)
    end
  end

  def durational?
    type == 'durational'
  end

  def instantaneous?
    type == 'istantaneous'
  end

  private

  def calculate_end_at
    occur_at + duration
  end

  def calculate_occur_at
    end_at - duration
  end

  def calculate_duration
    (end_at - occur_at).round(2)
  end

  def set_device_id
    self.device_id = Moped::BSON::ObjectId find_id(device)
  end
end
