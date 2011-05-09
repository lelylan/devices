class ConsumptionsController < ApplicationController
  before_filter :parse_json_body, only: %w(create update)
  before_filter :find_owned_resources
  before_filter :find_resource, only: %w(show destroy)  

  def index
    @consumptions = @consumptions.page(params[:page]).per(params[:per])
  end

  def show
  end

  def create
    @consumption = Consumption.base(json_body, request, current_user)
    if @consumption.save
      render "show", status: 201, location: @consumption.uri
    else
      render_422 "notifications.document.not_valid", @consumption.errors
    end
  end

  # The #update is not defined because you could risk to change
  # the type and other info, making some messes. Even more, it 
  # should be a value sent from the device, and it update it.

  def destroy
    @consumption.destroy
    head 204
  end


  private

    def find_owned_resources
      @consumptions = Consumption.where(created_from: current_user.uri)
    end

    def find_resource
      @consumption = @consumptions.find(params[:id])
    end
end
