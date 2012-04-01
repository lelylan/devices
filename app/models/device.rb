class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :created_from
  field :name
  field :type_uri
  field :labels, type: Array, default: []

  attr_accessor :physical  
  attr_accessible :name, :type_uri, :physical, :labels

  embeds_many :device_properties  # properties inherited from type
  embeds_many :device_physicals   # physical devices

  validates :created_from, presence: true, url: true
  validates :name, presence: true
  validates :type_uri, presence: true, url: true

  before_create :synchronize_type
  before_save :create_physical_connection



  # ----------------------------
  # Physical device assignment
  # ----------------------------

  # Enable bulk assignment of one phisical to a device.
  # If an Array of physical device is sent an error is raised.
  def create_physical_connection
    if physical.is_a? Hash
      device_physicals.destroy_all
      device_physicals = build_device_physical || []
    elsif not physical.nil?
      raise Mongoid::Errors::InvalidType.new(::Hash, physical)
    end
  end

  # Build a new device physical without saving it.
  # In this way we can check if it is valid or not.
  def build_device_physical
    device_physical = device_physicals.new(physical)
    validate_device_phisical(device_physical)
    [device_physical]
  end

  # Raise an error if the physical device connection is not valid
  def validate_device_phisical(device_physical)
    unless device_physical.valid?
      raise Mongoid::Errors::Validations.new(device_physical)    
    end
  end

  # Check if the device has a physical connection.
  # Return true if a physical connection is present.
  def physical_connection?
    !device_physicals.empty?
  end


  # ----------------------
  # Type synchronization
  # ----------------------

  # Inherit properties and functions from the selected type
  def synchronize_type
    type = Lelylan::Type.type(type_uri)
    synchronize_properties(type.properties)
  end

  # Sync properties
  def synchronize_properties(properties)
    device_properties.destroy_all
    properties.each do |property|
      create_device_property(property)
    end
  end

  # Create a device property
  def create_device_property(property)
    device_properties.build(
      uri: property.uri,
      name: property.name,
      value: property[:default] || '' # Hashiw::Rash bug does not allow the usage of default as key
    )
  end


  # ----------------------------------
  # Update device properties
  # ----------------------------------

  def synchronize_device(properties)
    update_properties(properties)
    synchronize_physical(properties) if physical_connection?
    return self
  end

  # Update the device properties.
  def update_properties(properties)
    properties.each do |property|
      property = HashWithIndifferentAccess.new(property)
      res = device_properties.where(uri: property[:uri]).first
      res.value = property[:value]
    end
    self.save
  end

  # Update physical device.
  def synchronize_physical(properties)
    options = { body: { properties: properties }.to_json, 
                headers: { 'Content-Type' => 'application/json', 'Accept'=>'application/json' } }
    HTTParty.put device_physicals.first.uri, options
    # For now we do not check the result
  end
end
