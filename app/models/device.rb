class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  field :resource_owner_id, type: Moped::BSON::ObjectId
  field :name
  field :type_id, type: Moped::BSON::ObjectId
  field :pending, type: Boolean, default: false

  attr_accessor  :type
  attr_protected :resource_owner_id, :type_id

  embeds_many :properties, class_name: 'DeviceProperty', cascade_callbacks: true
  embeds_one  :physical,   class_name: 'DevicePhysical', cascade_callbacks: true

  validates :resource_owner_id, presence: true
  validates :name, presence: true
  validates :type, presence: true, uri: true, on: :create

  before_create :synchronize_type

  def synchronize_type
    type_id = find_id type
    type = Type.find type_id
    synchronize_type_properties(type.property_ids)
  end

  private

  def synchronize_type_properties(type_property_ids)
    type_properties = Property.in(id: type_property_ids)
    self.properties = type_properties.map { |p| synchronize_type_property p }
  end

  def synchronize_type_property(type_property)
    property = properties.where(id: type_property.id).first
    property ? { property_id: property.id, value: property.value} : { property_id: type_property.id, value: type_property.default}
  end
end




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
