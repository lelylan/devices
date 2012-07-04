class PhysicalsController < ApplicationController
<<<<<<< HEAD
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

=======
  before_filter :parse_json_body, only: :create
  before_filter :find_owned_resources
  before_filter :find_resource
  
  def create
    @device.device_physicals.create!(json_body)
    @device.destroy_previous_physical
    render '/devices/show', status: 201, location: @device.uri
  end

  def destroy
    @device.device_physicals.destroy_all
    render '/devices/show'
  end
  
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750

  private

    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:id])
    end
end
