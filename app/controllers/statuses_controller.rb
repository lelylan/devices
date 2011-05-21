class StatusesController < ApplicationController
  before_filter :parse_json_body
  before_filter :find_owned_resources
  before_filter :find_resource
  before_filter :find_statuses
  before_filter :find_status

  def show
    render json: @status
  end
  
  private 

    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:device_id])
    end
    
    def find_statuses
      # TODO: remove the param type_uri which is already known
      @statuses = @device.type_representation(@device.type_uri)[:statuses]
      pp @statuses.map { |s| s[:uri]}
    end

    def find_status
      @status = Status.find_matching_status(@device.device_properties, @statuses).first
    end
end
