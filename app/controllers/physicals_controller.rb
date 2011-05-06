class PhysicalsController < ApplicationController
  before_filter :parse_json_body, only: :create
  before_filter :find_owned_resources
  before_filter :find_resource
  
  def create
    @device.device_physicals.create!(json_body)
    @device.destroy_previous_physical
    render "/devices/show", status: 201, location: @device.uri
  end

  def destroy
    @device.device_physicals.destroy_all
    head 204
  end
  

  private

    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:id])
    end
end
