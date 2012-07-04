class Device
  include Mongoid::Document
  include Mongoid::Timestamps
<<<<<<< HEAD

  field :created_from
  field :name
  field :type_uri
  field :pending, type: Boolean, default: false
  field :labels, type: Array, default: []

  attr_accessor :physical  
  attr_accessible :name, :type_uri, :physical, :labels

  embeds_many :device_properties  # properties inherited from type
  embeds_one :device_physical     # physical device

  validates :created_from, presence: true, url: true
  validates :name, presence: true
  validates :type_uri, presence: true, url: true

  before_create :synchronize_type
  before_save :create_physical_connection


  # ----------------------------
  # Physical device assignment
  # ----------------------------

  # Enable bulk assignment of one physical device to a device.
  # If an Array of physical device is sent an error is raised.
  def create_physical_connection
    if physical.is_a? Hash
      device_physical = build_device_physical(physical)
      validate_device_physical(device_physical)
    elsif not physical.nil?
      raise Mongoid::Errors::InvalidType.new(::Hash, physical)
    end
  end

  # Raise an error if the physical device connection is not valid
  def validate_device_physical(device_physical)
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
  end

  # Sync properties
  def synchronize_properties(properties)
=======
  include Lelylan::Document::Base

  field :uri
  field :created_from
  field :name
  field :type_uri
  field :type_name
  
  attr_accessible :name, :type_uri

  embeds_many :device_categories  # device category (inherited from type)
  embeds_many :device_properties  # device properties (inherited from type)
  embeds_many :device_functions   # device functions (inherited from type)
  embeds_many :device_physicals   # physical devices to control

  validates :uri, url: true
  validates :created_from, url: true
  validates :name, presence: true
  validates :type_uri, presence: true, url: true

  # --------------
  # TYPE SYNC
  # --------------

  # Inherit properties and functions from the selected type
  def sync_type(type_uri)
    type = Lelylan::Type.type(type_uri)
    sync_categories(type.categories)
    sync_properties(type.properties)
    sync_functions(type.functions)
    sync_type_name(type.name)
  end

  # Sync categories
  def sync_categories(categories)
    device_categories.destroy_all
    categories.each do |category|
      create_device_category(category)
    end
  end

  # Sync properties
  def sync_properties(properties)
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
    device_properties.destroy_all
    properties.each do |property|
      create_device_property(property)
    end
  end

<<<<<<< HEAD
  # Create a device property
  def create_device_property(property)
    device_properties.build(
      uri: property.uri,
      name: property.name,
      value: property[:default] || '' # Hashiw::Rash bug does not allow the usage of default as key
    )
  end


  # --------------------------
  # Update device properties
  # --------------------------

  def synchronize_device(properties, params)
    update_properties(properties, params)
    synchronize_physical(properties, params)
    return self
  end

  # Update the device properties.
  def update_properties(properties, params)
    properties.each do |property|
      property = HashWithIndifferentAccess.new(property)
      res = device_properties.where(uri: property[:uri]).first
      res.value = property[:value]
    end

    # self.save is made into #check_pending 
    # when pending is 'start' you must take the older values and set them to pending
    # when pending is 'update' you must not update the property values
    # when pending is 'close' you must not update the property values, but only close the pending
    check_pending(params)
  end

  # Update physical device.
  # TODO change with a proper library call
  def synchronize_physical(properties, params)
    if device_physical and params[:source] != 'physical'
      options = { body: { properties: properties }.to_json, 
                  headers: { 'Content-Type' => 'application/json', 'Accept'=>'application/json' } }
      HTTParty.put device_physical.uri, options
      # For now we do not check the result
    end
  end


  # -----------------------
  # Create device history
  # -----------------------
  def create_history(user_uri)
    device = DeviceDecorator.decorate(self)
    params = {device_uri: device.uri, created_from: user_uri }
    History.create_history(params, device_properties)
  end


  # -----------------------
  # Create pending status
  # -----------------------
  def check_pending(params)
    params[:pending] = 'start' if params[:pending].nil?

    start_pending(params)  if device_physical and params[:pending] == 'start'
    update_pending(params) if device_physical and params[:pending] == 'update'
    close_pending(params)  if device_physical and params[:pending] == 'close'

    self.save
  end

  def start_pending(params)
    self.pending = true
    device_properties.each { |p| p.pending = p.value_was }
  end
  
  def update_pending(params)
    self.pending = true
    device_properties.each { |p| p.pending = p.value }
    device_properties.each { |p| p.reset_value! }
  end

  def close_pending(params)
    self.pending = false
    device_properties.each { |p| p.pending = p.value }
  end

=======
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

  # Get tge properties to change from the function and from the 
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
        dp.pending = pendings_hash[dp.uri].inject(:|) 
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
    # Create a device category relation
    def create_device_category(category)
      device_categories.create!(
        uri: category.uri,
        name: category.name
      )
    end

    # Create a device property relation
    def create_device_property(property)
      device_properties.create!(
        uri: property.uri,
        name: property.name,
        value: property[:default] # Hashiw::Rash bug does not allow the usage of default as key
      )
    end

    # Create a device function relation
    def create_device_function(function)
      device_functions.create!(
        uri: function.uri,
        name: function.name
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
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
end
