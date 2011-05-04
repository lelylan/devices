class DevicesController < ApplicationController
  before_filter :parse_json_body, only: %w(create update)
  before_filter :find_owned_resources
  before_filter :find_resource, only: %w(show update destroy)

  def index
  end

  def show
  end

  def create
    @device = Device.base(json_body, request, current_user)
    if @device.save
      render "show", status: 201, location: @device.uri
    else
      render_422 "notifications.document.not_valid", @device.errors
    end
  end

  def update
    if @device.update_attributes(json_body)
      render "show", status: 200, location: @device.uri
    else
      render_422 "notifications.document.not_valid", @device.errors
    end
  end

  def destroy
    @device.destroy
    head 204
  end


  private

    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:id])
    end
end
