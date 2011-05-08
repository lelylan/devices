class HistoriesController < ApplicationController
  before_filter :find_owned_resources
  before_filter :find_resource 
  before_filter :find_pendings

  def index
    @histories.page(params[:page]).per(params[:per])
  end
  
  private 
  
    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:device_id])
    end

    def find_pendings
      @histories = History.where(device_uri: @device.uri)
    end
end
