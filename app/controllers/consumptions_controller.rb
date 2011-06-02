class ConsumptionsController < ApplicationController
  before_filter :parse_json_body, only: %w(create update)
  before_filter :find_owned_resources
  before_filter :find_device, only: 'index'
  before_filter :find_resource, only: %w(show destroy)  
  before_filter :filter_params, only: 'index'

  def index
    @consumptions = @consumptions.page(params[:page]).per(params[:per])
  end

  def show
  end

  def create
    @consumption = Consumption.base(json_body, request, current_user)
    if @consumption.save
      render 'show', status: 201, location: @consumption.uri
    else
      render_422 'notifications.document.not_valid', @consumption.errors
    end
  end

  # The #update is not defined because you could risk to change
  # the type and other info, making some messes. Even more, it 
  # should be a value sent from the device, and it update it.

  def destroy
    @consumption.destroy
    render 'show', status: 200
  end


  private

    def find_owned_resources
      @consumptions = Consumption.where(created_from: current_user.uri)
    end

    def find_device
      if params[:device_id]
        @device = Device.find(params[:device_id])
        @consumptions = @consumptions.where(device_uri: @device.uri)
      end
    end

    def find_resource
      @consumption = @consumptions.find(params[:id])
    end

    def filter_params
      @consumptions = @consumptions.where(type: params[:type]) if params[:type]
      @consumptions = @consumptions.where(:occur_at.gte => Chronic.parse(params[:from])) if params[:from]
      @consumptions = @consumptions.where(:occur_at.lte => Chronic.parse(params[:to])) if params[:to]
    end
end
