class FunctionsController < ApplicationController
  before_filter :parse_json_body
  before_filter :find_owned_resources
  before_filter :find_resource 
  before_filter :find_function

  def update
    # TODO: move this method into device_function and call it to_properties
    properties = @device.function_to_parameters(@device_function.function_uri, json_body[:properties])
    json = {}
    if @device.device_physical
      #response = @device.send_properties_to_physical(properties)
      physical = @device.device_physical
      json = JSON.parse(
        HTTParty.post(physical.unite_node_uri, 
          query: { id: physical.physical_id },
          body:  { properties: properties }
        ).body
      )
      json = HashWithIndifferentAccess.new(json)
      properties = json[:properties]
    end
    # change_device_properties
    properties.each do |property|
      res = @device.device_properties.where(property_uri: property[:uri]).first
      res.value = property[:value]
    end
    @device.save
    render "/devices/show", status: 200, location: @device.uri
  end
  
  private 
  
    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:id])
    end

    def find_function
      @device_function = @device.device_functions.where(function_uri: params[:function_uri]).first
      unless @device_function
        render_404 "notifications.document.not_found", {uri: request.url}
      end
    end
end
