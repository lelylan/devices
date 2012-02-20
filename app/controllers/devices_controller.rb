class DevicesController < ApplicationController
  respond_to :json
  before_filter :find_owned_resources

  def index
    @devices = @devices.page(params[:page]).per(params[:per])
  end


  private

    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

end
