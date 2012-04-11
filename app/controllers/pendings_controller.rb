class PendingsController < ApplicationController
  before_filter :find_owned_resources
  before_filter :find_resource


  def show
  end

  private

    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:id])
      @device = DeviceDecorator.decorate(@device)
    end
end
