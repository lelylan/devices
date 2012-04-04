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
    @device = Device.new(body)
    @device.created_from = current_user.uri
    if @device.save
      render 'show', status: 201, location: DeviceDecorator.decorate(@device).uri
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
    render 'show'
    @device.destroy
  end



  private

    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    # TODO: put logic into model.
    def pagination
      params[:per] = (params[:per] || Settings.pagination.per).to_i
      if params[:start]
        uri = Addressable::URI.parse(params[:start])
        @devices = @devices.where(:_id.gt => uri.basename)
      end
    end

    # TODO: put logic into model.
    def search_params
      @devices = @devices.where('name' => /.*#{params[:name]}.*/i) if params[:name]
      @devices = @devices.where('type_uri' => params[:type_uri]) if params[:type_uri]
      if (params[:property_uri] and params[:property_value])
        @devices = @devices.where('device_properties' => { '$elemMatch' => {uri: params[:property_uri], value: params[:property_value]}})
      else
        @devices = @devices.where('device_properties.uri' => params[:property_uri]) if params[:property_uri]
        @devices = @devices.where('device_properties.value' => params[:property_value]) if params[:property_value]
      end
    end 

    def find_resource
      @device = @devices.find(params[:id])
    end
end
