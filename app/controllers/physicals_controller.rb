class PhysicalsController < ApplicationController
  before_filter :find_owned_resources
  before_filter :find_resource


  def update
    @device.physical = JSON.parse(request.body.read)
    @device.create_physical_connection
    if @device.save
      render 'devices/show'
    else
      render_422 "notifications.resource.not_valid", @device.errors
    end
  end

  def destroy
    @device.device_physical.destroy
    @device.reload
    render 'devices/show'
  end


  private 

    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:id])
    end
end
