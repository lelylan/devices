class FunctionsController < ApplicationController
<<<<<<< HEAD
  before_filter :find_owned_resources
  before_filter :find_resource
  before_filter :find_function
  before_filter :merge_properties
  before_filter :status

  def update
    @device.synchronize_device(@properties, params)
    @device.create_history(current_user.uri)
    @device.check_pending(params)
    render '/devices/show', status: @status
  end

  private 

=======
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
  
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:id])
    end

    def find_function
<<<<<<< HEAD
      type = Lelylan::Type.type(@device.type_uri)
      @function = type.functions.select{ |function| function.uri == params[:uri] }.first
      render_404 'notifications.function.not_found', params[:uri] if not @function
    end

    def merge_properties
      @properties = body_properties
      function_properties = @function.properties.map {|property| {uri: property.uri, value: property.value}}
      function_properties.each do |property|
        @properties.push(property) unless contains_property(property[:uri])
      end
    end

    def status
      @status = @device.device_physical ? 202 : 200
    end


      # -----------------
      # Helper methods
      # -----------------
      def body_properties
        @body = request.body.read
        @properties = @body.empty? ? [] : JSON.parse(@body)['properties']
      end

      def contains_property(uri)
        @properties.any? {|property| property.has_value? uri}
      end
=======
      @device_function = @device.device_functions.where(uri: params[:uri]).first
      unless @device_function
        render_404 "notifications.document.not_found", {uri: request.url}
      end
    end
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
end
