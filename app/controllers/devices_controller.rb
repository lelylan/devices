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
    render 'index', json: @devices
  end

  def show
    if stale?(@device)
      render 'show', json: @device
    end
  end

  def create
    @device = Device.new(params)
    @device.resource_owner_id = current_user.id
    if @device.save!
      render 'show', json: @device, status: 201, location: DeviceDecorator.decorate(@device).uri
    else
      render_422 'notifications.resource.not_valid', @device.errors
    end
  end

  def update
    if @device.update_attributes!(params)
      render 'show', json: @device
    else
      render_422 'notifications.resource.not_valid', @device.errors
    end
  end

  def destroy
    render 'show', json: @device
    @device.destroy
  end

  # TODO: understand why if you use resource it does not work.
  def privates
    resource = { id: @device.id, name: @device.name, secret: @device.secret, activation_code: @device.activation_code, uri: DeviceDecorator.decorate(@device).uri }
    render 'show', json: resource, serializer: SecretSerializer
  end

  private


  def find_owned_resources
    @devices = Device.where(resource_owner_id: current_user.id)
    @devices.each(&:synchronize_type_properties) # TODO performance caching (N+1)
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
    @devices = @devices.where(pending: find_id(params[:pending])) if params[:pending]
  end

  # TODO: see if you are able to build a query to match multiple properties.
  def search_properties(match = {})
    if params[:properties]
      match.merge!({ property_id: Moped::BSON::ObjectId(find_id(params[:properties][:uri])) }) if params[:properties][:uri]
      match.merge!({ value: params[:properties][:value] }) if params[:properties][:value]
      match.merge!({ physical: params[:properties][:physical] }) if params[:properties][:physical]
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
