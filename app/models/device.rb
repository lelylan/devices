#class Device
  #include Mongoid::Document
  #include Mongoid::Timestamps

  #field :created_from
  #field :name
  #field :type_uri
  #field :pending, type: Boolean, default: false
  #field :labels, type: Array, default: []

  #attr_accessor :physical  
  #attr_accessible :name, :type_uri, :physical, :labels

  #embeds_many :device_properties  # properties inherited from type
  #embeds_one :device_physical     # physical device

  #validates :created_from, presence: true, url: true
  #validates :name, presence: true
  #validates :type_uri, presence: true, url: true

  #before_create :synchronize_type
  #before_save :create_physical_connection


  ## ----------------------------
  ## Physical device assignment
  ## ----------------------------

  ## Enable bulk assignment of one physical device to a device.
  ## If an Array of physical device is sent an error is raised.
  #def create_physical_connection
    #if physical.is_a? Hash
      #device_physical = build_device_physical(physical)
      #validate_device_physical(device_physical)
    #elsif not physical.nil?
      #raise Mongoid::Errors::InvalidType.new(::Hash, physical)
    #end
  #end

  ## Raise an error if the physical device connection is not valid
  #def validate_device_physical(device_physical)
    #unless device_physical.valid?
      #raise Mongoid::Errors::Validations.new(device_physical)    
    #end
  #end


  ## ----------------------
  ## Type synchronization
  ## ----------------------

  ## Inherit properties and functions from the selected type
  #def synchronize_type
    #type = Lelylan::Type.type(type_uri)
    #synchronize_properties(type.properties)
  #end

  ## Sync properties
  #def synchronize_properties(properties)
    #device_properties.destroy_all
    #properties.each do |property|
      #create_device_property(property)
    #end
  #end

  ## Create a device property
  #def create_device_property(property)
    #device_properties.build(
      #uri: property.uri,
      #name: property.name,
      #value: property[:default] || '' # Hashiw::Rash bug does not allow the usage of default as key
    #)
  #end


  ## --------------------------
  ## Update device properties
  ## --------------------------

  #def synchronize_device(properties, params)
    #update_properties(properties, params)
    #synchronize_physical(properties, params)
    #return self
  #end

  ## Update the device properties.
  #def update_properties(properties, params)
    #properties.each do |property|
      #property = HashWithIndifferentAccess.new(property)
      #res = device_properties.where(uri: property[:uri]).first
      #res.value = property[:value]
    #end

    ## self.save is made into #check_pending 
    ## when pending is 'start' you must take the older values and set them to pending
    ## when pending is 'update' you must not update the property values
    ## when pending is 'close' you must not update the property values, but only close the pending
    #check_pending(params)
  #end

  ## Update physical device.
  ## TODO change with a proper library call
  #def synchronize_physical(properties, params)
    #if device_physical and params[:source] != 'physical'
      #options = { body: { properties: properties }.to_json, 
                  #headers: { 'Content-Type' => 'application/json', 'Accept'=>'application/json' } }
      #HTTParty.put device_physical.uri, options
      ## For now we do not check the result
    #end
  #end


  ## -----------------------
  ## Create device history
  ## -----------------------
  #def create_history(user_uri)
    #device = DeviceDecorator.decorate(self)
    #params = {device_uri: device.uri, created_from: user_uri }
    #History.create_history(params, device_properties)
  #end


  ## -----------------------
  ## Create pending status
  ## -----------------------
  #def check_pending(params)
    #params[:pending] = 'start' if params[:pending].nil?

    #start_pending(params)  if device_physical and params[:pending] == 'start'
    #update_pending(params) if device_physical and params[:pending] == 'update'
    #close_pending(params)  if device_physical and params[:pending] == 'close'

    #self.save
  #end

  #def start_pending(params)
    #self.pending = true
    #device_properties.each { |p| p.pending = p.value_was }
  #end
  
  #def update_pending(params)
    #self.pending = true
    #device_properties.each { |p| p.pending = p.value }
    #device_properties.each { |p| p.reset_value! }
  #end

  #def close_pending(params)
    #self.pending = false
    #device_properties.each { |p| p.pending = p.value }
  #end

#end
