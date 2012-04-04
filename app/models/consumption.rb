class Consumption
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri
  field :created_from
  field :device_uri
  field :type, default: 'instantaneous'
  field :value
  field :unit, default: 'KWH'
  field :occur_at, type: Time
  field :end_at, type: Time
  field :duration, type: Float
  field :labels, type: Array, default: []

  attr_accessible :device_uri, :type, :value, :unit, :occur_at, :end_at, :duration, :labels

  validates :uri, presence: true, url: true
  validates :created_from, presence: true, url: true
  validates :device_uri, presence: true, url: true
  validates :type, inclusion: { in: %w(instantaneous durational) }
  validates :value, presence: true
  validates :unit, inclusion: { in: %w(KWH) }
  validates :occur_at, presence: true
  validates :end_at, presence: true, if: :durational?
  validates :duration, presence: true, if: :durational?
  
  before_validation :normalize_timings


  # Normalize timings when the measurament type is durational so
  # that we can have occur_at, end_at and duration also if one of
  # them is missing. When more than one is missing an error is raised
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
      end_at - occur_at
    end
end