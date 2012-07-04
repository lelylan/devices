class PropertiesController < ApplicationController
<<<<<<< HEAD
  before_filter :find_owned_resources
  before_filter :find_resource
  before_filter :find_properties
  before_filter :status

  def update
    @device.synchronize_device(@properties, params)
    @device.create_history(current_user.uri)
    render '/devices/show', status: @status
=======
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
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
  end

  private 

    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:id])
    end
<<<<<<< HEAD

    def find_properties
      @body = request.body.read
      @properties = @body.empty? ? [] : JSON.parse(@body)['properties']
    end

    def status
      @status = @device.device_physical ? 202 : 200
    end
=======
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
end
