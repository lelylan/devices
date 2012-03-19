class DevicesController < ApplicationController
  before_filter :find_owned_resources
  before_filter :pagination, only: 'index'
  before_filter :search_params, only: 'index'
  before_filter :find_resource, only: %w(show update destroy)



  def index
    @devices = @devices.limit(params[:per])
  end

  def show
  end

  def create
    body = JSON.parse(request.body.read)
    @device = Device.base(body, request, current_user)
    if @device.save
      @device.synchronize_type
      render 'show', status: 201, location: @device.uri
    else
      render_422 "notifications.resource.not_valid", @device.errors
    end
  end

  def update
    body = JSON.parse(request.body.read)
    body.delete('type_uri')
    if @device.update_attributes(body)
      render 'show'
    else
      render_422 'notifications.resource.not_valid', @device.errors
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

    def pagination
      params[:per] = (params[:per] || Settings.pagination.per).to_i
      from = Device.where(uri: params[:from]).first if params[:from]
      @devices = @devices.where(:_id.gt => from.id) if from
    end

    def search_params
      @devices = @devices.where('name' => /.*#{params[:name]}.*/i) if params[:name]
      @devices = @devices.where('type_uri' => params[:type_uri]) if params[:type_uri]
      @devices = @devices.any_in('device_properties.uri' => [params[:property_uri]]) if params[:property_uri]
      @devices = @devices.where('device_properties.value' => params[:property_value]) if params[:property_value]
    end 

    def find_resource
      @device = @devices.find(params[:id])
    end
end
