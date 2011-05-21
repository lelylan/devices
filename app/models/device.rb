class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :uri
  field :created_from
  field :name
  field :type_uri
  field :type_name
  
  attr_accessible :name, :type_uri

  embeds_many :device_properties  # device properties (inherited from type)
  embeds_many :device_functions   # device functions (inherited from type)
  embeds_many :device_physicals   # physical devices to control
  embeds_many :device_locations   # locations the device is contained in

  validates :uri, url: true
  validates :created_from, url: true
  validates :name, presence: true
  validates :type_uri, presence: true, url: true

  # --------------
  # TYPE SYNC
  # --------------

  # Inherit properties and functions from the selected type
  def sync_type(type_uri)
    type = type_representation(type_uri)
    sync_properties(type[:properties])
    sync_functions(type[:functions])
    sync_type_name(type[:name])
  end

  # Get the JSON type representation
  def type_representation(type_uri)
    json = JSON.parse(HTTParty.get(type_uri).body)
    HashWithIndifferentAccess.new(json)
  end

  # Sync properties
  def sync_properties(properties)
    device_properties.destroy_all
    properties.each do |property|
      create_device_property(property)
    end
  end

  # Sync functions
  def sync_functions(functions)
    device_functions.destroy_all
    functions.each do |function|
      create_device_function(function)
    end
  end

  # Add the type name to the model
  def sync_type_name(type_name)
    self.type_name = type_name
    self.save
  end

  # -----------------------
  # FUNCTION TO PROPERTIES
  # -----------------------

  # Get tge properties to change from the funciton and from the 
  # body of the function request
  def sync_physical(properties)
    response = HTTParty.put(device_physical.unite_node_uri, 
      query: { id: device_physical.physical_id },
      body:  { properties: properties })
    body = JSON.parse(response.body)
    HashWithIndifferentAccess.new(body)[:properties]
  end

  # Apply changes received from physical to the device
  def sync_properties_with_physical(properties)
     properties.each do |property|
      res = device_properties.where(uri: property[:uri]).first
      res.value = property[:value]
    end
    self.save
  end

  # --------
  # PENDING
  # --------

  # Create a pending resource
  def create_pending(properties, function, request)
    pending = Pending.create_pending(self, function, request)
    pending.create_pending_properties(self, properties)
  end

  # Update the pending values for every device property connection.
  # This method should be used any time a change happens to the device.
  def update_pending_properties
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
        dp.pending = pendings_hash[dp.uri].inject(:&) 
      end
    end
    # Save the changes
    save
  end
  

  # ------
  # EXTRA
  # ------

  def device_physical
    device_physicals.first
  end

  def destroy_previous_physical
    unless device_physicals.length == 1
      device_physicals.first.destroy
    end
  end

  private 

    # Create a device property relation
    def create_device_property(property)
      device_properties.create!(
        uri: property[:uri],
        name: property[:name],
        value: property[:default]
      )
    end

    # Create a device function relation
    def create_device_function(function)
      device_functions.create!(
        uri: function[:uri],
        name: function[:name]
      )
    end

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
