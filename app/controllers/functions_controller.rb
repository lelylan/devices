class FunctionsController < ApplicationController
  before_filter :parse_json_body
  before_filter :find_owned_resources
  before_filter :find_resource 
  before_filter :find_function

  def update
    # TODO: move this method into device_function and call it to_properties
    properties = @device.function_to_parameters(@device_function.function_uri, json_body[:properties])
    puts "::::" +  properties.inspect

    if @device.device_physical
      physical = @device.device_physical
      json = JSON.parse(
        HTTParty.post(physical.unite_node_uri, 
          query: { id: physical.physical_id },
          body:  { properties: properties }
        ).body
      )
      puts "::: JSON " + json.inspect 
      #response = @device.send_properties_to_physical(properties)

    end
    head 200
  end
  
  private 
  
    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:device_id])
    end

    def find_function
      @device_function = @device.device_functions.where(uri: request.url).first
      unless @device_function
        render_404 "notifications.document.not_found", {uri: request.url}
      end
    end
end
