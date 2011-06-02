class HistoriesController < ApplicationController
  before_filter :find_owned_resources
  before_filter :find_resource 
  before_filter :find_histories
  before_filter :filter_params

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

    def find_histories
      @histories = History.where(device_uri: @device.uri)
    end
    
    def filter_params
      @histories = @histories.where(:created_at.gte => Chronic.parse(params[:from])) if params[:from]
      @histories = @histories.where(:created_at.lte => Chronic.parse(params[:to]))   if params[:to]
    end
end
