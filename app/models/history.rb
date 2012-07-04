class History
  include Mongoid::Document
  include Mongoid::Timestamps
<<<<<<< HEAD

  field :device_uri
  field :created_from

  attr_accessible :device_uri, :created_from

  embeds_many :history_properties

  validates :device_uri, presence:true, url: true
  validates :created_from, presence:true, url: true


  # Create an history resource with the connected properties
  def self.create_history(params, properties)
    history     = History.new(params)
    history.create_properties(properties)
    history.save! and return history
  end

  # Add properties to the history resource
  def create_properties(properties)
=======
  include Lelylan::Document::Base

  field :uri
  field :device_uri

  embeds_many :history_properties

  validates :uri, presence: true, url: true
  validates :device_uri, presence:true, url: true


  def self.create_history(device_uri, properties, request)
    history = create_base_history(device_uri, request)
    history.create_history_properties(properties)
    return history
  end

  def self.create_base_history(device_uri, request)
    history = History.new(device_uri: device_uri)
    history.uri = History.base_uri(request, history)
    history.save! and return history
  end

  def create_history_properties(properties)
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
    properties.each do |property|
      self.history_properties.create!(
        uri: property[:uri],
        value: property[:value])
    end
  end
end
