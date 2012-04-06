class PropertiesController < ApplicationController
  before_filter :find_owned_resources
  before_filter :find_resource
  before_filter :find_properties
  before_filter :status

  def update
    @device.synchronize_device(@properties, params)
    @device.create_history({created_from: current_user.uri})
    @device.check_pending(params)
    render '/devices/show', status: @status
  end

  private 

    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:id])
    end

    def find_properties
      @body = request.body.read
      @properties = @body.empty? ? [] : JSON.parse(@body)['properties']
    end

    def status
      @status = @device.device_physical ? 202 : 200
    end
end
