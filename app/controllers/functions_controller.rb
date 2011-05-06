class FunctionsController < ApplicationController
  before_filter :parse_json_body
  before_filter :find_owned_resources
  before_filter :find_resource 
  before_filter :find_function

  def update
    # TODO: move this method into device_function and call it to_properties
    # Transform the function to the properties to send to the physical device
    properties = @device.to_parameters(@device_function.function_uri, json_body[:properties])
    # Send the properties to the physical device
    properties = @device.sync_physical(properties) if @device.device_physical
    # Update the device properties with the ones received from the physical device
    @device.sync_properties_with_physical(properties)
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
