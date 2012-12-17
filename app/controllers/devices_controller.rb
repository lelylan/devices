class DevicesController < ApplicationController
  eventable_for 'device', resource: 'devices', only: %w(create update destroy)

  doorkeeper_for :index, :show, scopes: Settings.scopes.read.map(&:to_sym)
  doorkeeper_for :create, :update, :destroy, scopes: Settings.scopes.write.map(&:to_sym)
  doorkeeper_for :privates, scopes: %w(privates).map(&:to_sym)

  before_filter :find_owned_resources
  before_filter :find_filtered_resources
  before_filter :find_resource,     only: %w(show update destroy privates)
  before_filter :search_params,     only: %w(index)
  before_filter :search_properties, only: %w(index)
  before_filter :pagination,        only: %w(index)

  def index
    @devices = @devices.limit(params[:per])
    render json: @devices
  end

  def show
    render json: @device if stale?(@device)
  end

  def create
    @device = Device.new(params)
    @device.resource_owner_id = current_user.id
    if @device.save
      render json: @device, status: 201, location: DeviceDecorator.decorate(@device).uri
    else
      render_422 'notifications.resource.not_valid', @device.errors
    end
  end

  def update
    if @device.update_attributes(params)
      render json: @device
    else
      render_422 'notifications.resource.not_valid', @device.errors
    end
  end

  def destroy
    render json: @device
    @device.destroy
  end

  # TODO: understand why if you use @device it does not work.
  def privates
    resource = { id: @device.id, name: @device.name, secret: @device.secret, activation_code: @device.activation_code, uri: DeviceDecorator.decorate(@device).uri }
    render json: resource, serializer: PrivateSerializer
  end

  private


  def find_owned_resources
    @devices = Device.where(resource_owner_id: current_user.id)
  end

  def find_filtered_resources
    # TODO solution that temporarly solve the bug that should let you use
    # @devices.in(id: doorkeeper_token.device_ids) if not doorkeeper_token.device_ids.empty?
    if not doorkeeper_token.device_ids.empty?
      doorkeeper_token.device_ids.each {|id| @devices = @devices.or(id: id) }
    end
  end

  def find_resource
    @device = @devices.find(params[:id])
  end

  def search_params
    @devices = @devices.where('name' => /.*#{params[:name]}.*/i) if params[:name]
    @devices = @devices.where('physical' => /.*#{params[:physical]}.*/i) if params[:physical]
    @devices = @devices.where(type_id: find_id(params[:type])) if params[:type]
    @devices = @devices.where(pending: params[:pending].to_bool) if params[:pending]
  end

  # TODO: see if you are able to build a query to match multiple properties.
  def search_properties(match = {})
    if params[:properties]
      match.merge!({ property_id: Moped::BSON::ObjectId(find_id(params[:properties][:uri])) }) if params[:properties][:uri]
      match.merge!({ value: params[:properties][:value] }) if params[:properties][:value]
      match.merge!({ expected_value: params[:properties][:expected_value] }) if params[:properties][:expected_value]
      match.merge!({ pending: params[:properties][:pending].to_bool }) if params[:properties][:pending]
      @devices = @devices.where('properties' => { '$elemMatch' => match })
    end
  end

  def pagination
    params[:per] = (params[:per] || Settings.pagination.per).to_i
    params[:per] = Settings.pagination.per if params[:per] == 0
    params[:per] = Settings.pagination.max_per if params[:per] > Settings.pagination.max_per
    @devices = @devices.gt(id: find_id(params[:start])) if params[:start]
  end
end
