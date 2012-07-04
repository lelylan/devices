class Consumption
  include Mongoid::Document
  include Mongoid::Timestamps
<<<<<<< HEAD

  field :created_from
  field :device_uri
  field :type, default: 'instantaneous'
  field :value
  field :unit, default: 'kwh'
  field :occur_at, type: Time, default: lambda {Time.now}
=======
  include Lelylan::Document::Base

  field :uri
  field :created_from
  field :device_uri
  field :type, default: 'instantaneous'
  field :value, type: Float
  field :unit, default: 'kwh'
  field :occur_at, type: Time
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
  field :end_at, type: Time
  field :duration, type: Float

  attr_accessible :device_uri, :type, :value, :unit, :occur_at, :end_at, :duration

<<<<<<< HEAD
=======
  validates :uri, presence: true, url: true
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
  validates :created_from, presence: true, url: true
  validates :device_uri, presence: true, url: true
  validates :type, inclusion: { in: %w(instantaneous durational) }
  validates :value, presence: true
<<<<<<< HEAD
=======
  validates :unit, inclusion: { in: %w(kwh) }
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
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
