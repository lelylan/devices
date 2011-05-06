class DeviceFunction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :function_uri
  field :name

  validates :function_uri, url: true
  validates :name, presence: true

  embedded_in :device

  # Transform the function and the received body in the params
  # to send to the physical device  
  #
  #   function_to_properties("http://...", [body array of properties]) 
  def to_parameters(params_properties)
    function = function_representation
    properties = populate_properties(function[:properties], params_properties)
  end

  # Get the JSON function representation
  def function_representation
    json = JSON.parse(HTTParty.get(function_uri).body)
    HashWithIndifferentAccess.new(json)
  end

  # Populate the params to send to the physical device
  def populate_properties(function_properties, params_properties)
    keys = find_missing_keys(function_properties, params_properties)
    params_properties += add_missing_properties(keys, function_properties)
  end 

  
  private 

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
