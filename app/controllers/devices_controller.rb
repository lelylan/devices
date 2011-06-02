class DevicesController < ApplicationController
  before_filter :parse_json_body, only: %w(create update)
  before_filter :find_owned_resources
  before_filter :find_resource, only: %w(show update destroy)
  before_filter :filter_params, only: 'index'

  def index
    @devices = @devices.page(params[:page]).per(params[:per])
  end

  def show
  end

  def create
    @device = Device.base(json_body, request, current_user)
    if @device.save
      @device.sync_type(@device.type_uri)
      render 'show', status: 201, location: @device.uri
    else
      render_422 "notifications.document.not_valid", @device.errors
    end
  end

  def update
    if @device.update_attributes(json_body)
      @device.sync_type(@device.type_uri) if @device.type_uri_changed?
      render 'show'
    else
      render_422 'notifications.document.not_valid', @device.errors
    end
  end

  def destroy
    @device.destroy
    render 'show'
  end


  private

    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:id])
    end

    def filter_params
      # Device specific
      @devices = @devices.where('name' => /^#{params[:name]}/) if params[:name]
      @devices = @devices.where('type_name' => /^#{params[:type_name]}/) if params[:type_name]
      @devices = @devices.where(type_uri: params[:type]) if params[:type]
      @devices = @devices.any_in('device_categories.uri' => [params[:category]]) if params[:category]
      @devices = @devices.where('device_categories.name' => /^#{params[:category_name]}/) if params[:category_name]
    end 
end
