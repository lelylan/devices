class PendingsController < ApplicationController
  before_filter :find_owned_resources
  before_filter :find_resource 
  before_filter :find_pendings

  de
  private 
  
    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:id])
    end

    def find_function
      @device_pendings = Pendings.where(device_uri: @device.uri)
    end
end
