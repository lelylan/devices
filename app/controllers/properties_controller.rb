class PropertiesController < ApplicationController
  before_filter :parse_json_body
  before_filter :find_owned_resources
  before_filter :find_resource 

  def update
    # Retrieve the properties in the body
    properties = json_body[:properties]
    # Update the device properties with the ones received from the physical device
    @device.sync_properties_with_physical(properties)
    # Update (close) the pending resources
    Pending.update_pendings(@device.uri, properties)
    @device.update_pending_properties
    # Create an history resource when the physical changes
    history = History.create_history(@device.uri, properties, request)
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
end
