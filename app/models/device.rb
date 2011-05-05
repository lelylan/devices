class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :uri
  field :created_from
  field :name
  field :type_uri
  field :type_name
  
  attr_accessible :name

  embeds_many :device_properties  # device properties (inherited from type)
  embeds_many :device_functions   # device functions (inherited from type)
  embeds_many :device_physicals   # physical devices to control
  embeds_many :device_locations   # locations the device is contained in

  validates :uri, url: true
  validates :created_from, url: true
  validates :name, presence: true
  validates :type_uri, presence: true, url: true
  validates :type_name, presence: true

  # Inherit properties and functions from the selected type
  def sync_type(type_uri)
    type = type_representation(type_uri)
    sync_properties(type[:properties])
    sync_functions(type[:functions])
  end

  # Get the JSON type representation
  def type_representation(type_uri)
    json = JSON.parse(HTTParty.get(type_uri).body)
    HashWithIndifferentAccess.new(json)
  end

  # Sync properties
  def sync_properties(properties)
    
  end

  # Sync functions
  def sync_functions(functions)
  end
end
