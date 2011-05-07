class FunctionsController < ApplicationController
  before_filter :parse_json_body
  before_filter :find_owned_resources
  before_filter :find_resource 
  before_filter :find_function

  def update
    # Transform the function to the properties to send to the physical device
    properties = @device_function.to_parameters(json_body[:properties])
    # If a physical device is connected handle it
    if @device.device_physical
      # Send the properties to the physical device
      properties = @device.sync_physical(properties)
      # Create the pending resource
      pending = @device.create_pending(properties, @device_function, request)
    end

    #---- TO MOVE INTO /devices/{device-id}/properties -----

    # Update the device properties with the ones received from the physical device
    @device.sync_properties_with_physical(properties)
    # Update the pending resources
    Pending.update_pendings(@device.uri, properties)
    # Render the updated device representation
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
