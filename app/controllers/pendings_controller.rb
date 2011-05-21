class PendingsController < ApplicationController
  before_filter :find_owned_resources
  before_filter :find_resource 
  before_filter :find_pendings

  def index
    @pendings.page(params[:page]).per(params[:per])
  end
  
  private 
  
    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:device_id])
    end

    def find_pendings
      @pendings = Pending.where(device_uri: @device.uri, pending_status: true)
    end
end
