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
      # Create the pending resource
      # TODO: move the pending creation to the device model logic
      pending = @device.create_pending(properties, @device_function, request)
      @device.update_pending_properties
      # Send the properties to the physical device
      properties = @device.sync_physical(properties)
    else
      # If no phisical device is found add history
      history = History.create_history(@device.uri, properties, request) 
    end

    #---- TO REMOVE WHEN WE HAVE A REALTIME SYSTEM ENABLED  -----
    #---- This method needs to return only a 202 responce   -----
    #---- (it stay only in /devices/{device-id}/properties) -----

    # Update the device properties with the ones received from the physical device
    @device.sync_properties_with_physical(properties)
    # Update (close) the pending resources
    Pending.update_pendings(@device.uri, properties)

    if @device.device_physical
      # Create an history resource when the physical changes
      history = History.create_history(@device.uri, properties, request)
    end
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
      @device_function = @device.device_functions.where(uri: params[:uri]).first
      unless @device_function
        render_404 "notifications.document.not_found", {uri: request.url}
      end
    end
end
