class StatusesController < ApplicationController
  before_filter :parse_json_body
  before_filter :find_owned_resources
  before_filter :find_resource
  before_filter :find_statuses
  before_filter :find_status

  def show
    respond_to do |format|
      format.json { render json: JSON.pretty_generate(@status) }
      format.png  { redirect_to @status[:image] }
    end
  end
  
  private 

    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:device_id])
    end
    
    def find_statuses
      @statuses = Lelylan::Type.type(@device.type_uri).statuses
    end

    def find_status
      @status = Status.find_matching_status(@device.device_properties, @statuses).first
    end
end
