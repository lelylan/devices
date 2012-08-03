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

  accepts_nested_attributes_for :properties

  before_create :set_type_uri, :synchronize_type_properties

  def set_type_uri
    self.type_id = find_id type
  end

  def synchronize_type_properties
    type = Type.find type_id
    properties = Property.in(id: type.property_ids)
    device_properties = properties.map { |p| synchronize_type_property p }
  end

  private

  def synchronize_type_property(property)
    device_property = properties.where(property_id: property.id).first
    device_property ? { property_id: property.id, value: device_property.value} : { property_id: property.id, value: property.default }
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
