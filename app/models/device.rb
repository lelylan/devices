class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :uri
  field :created_from
  field :name
  field :type_uri
  field :labels, type: Array, default: []
  
  attr_accessor :physical  
  attr_accessible :name, :type_uri, :labels

  embeds_many :device_properties  # properties inherited from type
  embeds_many :device_physicals   # physical devices

  validates :uri, url: true
  validates :created_from, url: true
  validates :name, presence: true
  validates :type_uri, presence: true, url: true

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


  # ----------------------
  # Type synchronization
  # ----------------------

  # Inherit properties and functions from the selected type
  def synchronize_type
    type = Lelylan::Type.type(type_uri)
    synchronize_properties(type.properties)
    self.save
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
    device_properties.create!(
      uri: property.uri,
      name: property.name,
      value: property[:default] # Hashiw::Rash bug does not allow the usage of default as key
    )
  end


  # ------------------------
  # Function to properties
  # ------------------------

  # Properties change through the use of functions.
  # Return the updated properties 
  def synchronize_physical(properties)
    options = { body: { properties: properties }}
    response = HTTParty.put(device_physicals.first.uri, options)
    body = JSON.parse(response.body)
    HashWithIndifferentAccess.new(body)[:properties]
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

  # Check if the device has a physical connection.
  # Return true if a physical connection is present.
  def physical?
    !device_physicals.empty?
  end


  # ---------
  # Pending
  # ---------

  # Create a pending resource
  def create_pending(properties, function, request)
    pending = Pending.create_pending(self, function, request)
    pending.create_pending_properties(self, properties)
  end

  # Update the pending open for every device.
  # This method is used any time a change happens to the device.
  #
  # # Implementation that would work if boolean embedded document was going to be validated
  # device_properties.each do |property|
  #   open_pendings = Pending.where(
  #     device_uri: uri, pending_status: true,
  #     'pending_properties.uri' => property.uri, 
  #     'pending_properties.pending_status' => true
  #   )
  #   property.pending = !open_pendings.empty?
  # end
  def update_open_pendings
    pendings = Pending.open_pendings_for(uri)
    # if no pending resources are present set all pending values to false
    if pendings.empty? 
      device_properties.each do |device_property| 
        device_property.pending = false 
      end
    # if pendings resources are present check the open properties in them
    else
      pendings_hash = create_pendings_hash(pendings)
      device_properties.each do |dp| 
        dp.pending = pendings_hash[dp.uri].inject(:|) 
      end
    end
    # Save the changes
    save
  end


  private

    # Update the hash with the pending values (coming from pending resources)
    # which are true (open) or false (closed)
    def create_pendings_hash(pendings)
      pendings_hash = create_empty_pendings_hash
      pendings.each do |pending|
        pending.pending_properties.each do |pending_property| 
          pendings_hash[pending_property.uri] << pending_property.pending_status
        end
      end
      return pendings_hash
    end

    # Returns an hash with properties uri as keys and [] as vlaue
    def create_empty_pendings_hash
      Hash.new.tap do |hash|
        device_properties.each { |p| hash[p.uri] = [] }
      end
    end
end
