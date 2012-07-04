class DevicesController < ApplicationController
<<<<<<< HEAD
  before_filter :find_owned_resources
  before_filter :find_resource, only: %w(show update destroy)
  before_filter :search_params, only: 'index'
  before_filter :pagination, only: 'index'


  def index
    @devices = @devices.limit(params[:per])
=======
  before_filter :parse_json_body, only: %w(create update)
  before_filter :find_owned_resources
  before_filter :find_resource, only: %w(show update destroy)
  before_filter :filter_params, only: 'index'

  def index
    @devices = @devices.page(params[:page]).per(params[:per])
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
  end

  def show
  end

  def create
<<<<<<< HEAD
    body = JSON.parse(request.body.read)
    @device = Device.new(body)
    @device.created_from = current_user.uri
    if @device.save
      render 'show', status: 201, location: DeviceDecorator.decorate(@device).uri
    else
      render_422 "notifications.resource.not_valid", @device.errors
=======
    @device = Device.base(json_body, request, current_user)
    if @device.save
      @device.sync_type(@device.type_uri)
      render 'show', status: 201, location: @device.uri
    else
      render_422 "notifications.document.not_valid", @device.errors
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
    end
  end

  def update
<<<<<<< HEAD
    body = JSON.parse(request.body.read)
    body.delete('type_uri')
    if @device.update_attributes(body)
      render 'show'
    else
      render_422 'notifications.resource.not_valid', @device.errors
=======
    if @device.update_attributes(json_body)
      @device.sync_type(@device.type_uri) if @device.type_uri_changed?
      render 'show'
    else
      render_422 'notifications.document.not_valid', @device.errors
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
    end
  end

  def destroy
<<<<<<< HEAD
    render 'show'
    @device.destroy
  end



=======
    @device.destroy
    render 'show'
  end


>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
  private

    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

<<<<<<< HEAD
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
=======
    def find_resource
      @device = @devices.find(params[:id])
    end

    def filter_params
      # Device specific
      @devices = @devices.where('name' => /^#{params[:name]}/) if params[:name]
      # Type specific
      @devices = @devices.where('type_name' => /^#{params[:type_name]}/) if params[:type_name]
      @devices = @devices.where(type_uri: params[:type]) if params[:type]
      # Category specific
      @devices = @devices.any_in('device_categories.uri' => [params[:category]]) if params[:category]
      @devices = @devices.where('device_categories.name' => /^#{params[:category_name]}/) if params[:category_name]
      # Property specific
      @devices = @devices.any_in('device_properties.uri' => [params[:property]]) if params[:property]
      @devices = @devices.where('device_properties.name' => /^#{params[:property_name]}/) if params[:property_name]
      @devices = @devices.where('device_properties.value' => params[:property_value]) if params[:property_value]
      # Function specific
      @devices = @devices.any_in('device_functions.uri' => [params[:function]]) if params[:function]
      @devices = @devices.where('device_functions.name' => /^#{params[:function_name]}/) if params[:function_name]
    end 
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
end
