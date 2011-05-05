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

  # TYPE SYNC

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

  # FUNCTION TO PROPERTY FILLMENT
  # Transform the function and the received body in the params
  # to send to the physical device (if existing)
  def sync_physical_device(function_uri, json_body)
    function = function_representation(function_uri)
    properties = populate_properties(function[:properties], json_body)
  end

  # Get the JSON function representation
  def function_representation(function_uri)
    json = JSON.parse(HTTParty.get(function_uri).body)
    HashWithIndifferentAccess.new(json)
  end

  # Populate the params to send to the physical device
  def populate_properties(function_properties, params_properties)
    keys = find_missing_keys(function_properties, params_properties)
    params_properties += add_missing_properties(keys, function_properties)
  end

  private 

    # Create a device property relation
    def create_device_property(property)
      device_properties.create!(
        property_uri: property[:uri],
        name: property[:name],
        value: property[:default]
      )
    end

    # Create a device function relation
    def create_device_function(function)
      device_functions.create!(
        function_uri: function[:uri],
        uri: function_uri_for_device(function[:uri]),
        name: function[:name]
      )
    end

    def function_uri_for_device(function_uri)
      function_uri = Addressable::URI.parse(function_uri)
      uri + function_uri.path
    end


    def find_missing_keys(function_properties, params_properties)
      params_keys = params_properties.map{ |p| p[:uri] }
      function_keys = function_properties.map{ |p| p[:uri] }
      function_keys - params_keys
    end

    def add_missing_properties(missing_keys, function_properties)
      result = function_properties.collect do |property|
        if missing_keys.include?(property[:uri])
          {uri: property[:uri], value: property[:value]}
        end
      end
      return result.delete_if {|r| r.nil? }
    end

end
