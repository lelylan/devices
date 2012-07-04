class PendingsController < ApplicationController
  before_filter :find_owned_resources
<<<<<<< HEAD
  before_filter :find_resource


  def show
  end

  private

=======
  before_filter :find_resource 
  before_filter :find_pendings

  def index
    @pendings.page(params[:page]).per(params[:per])
  end
  
  private 
  
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
<<<<<<< HEAD
      @device = @devices.find(params[:id])
      @device = DeviceDecorator.decorate(@device)
=======
      @device = @devices.find(params[:device_id])
    end

    def find_pendings
      @pendings = Pending.where(device_uri: @device.uri, pending_status: true)
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
    end
end
