class DevicesController < ApplicationController

  doorkeeper_for :index, :show, scopes: Settings.scopes.read.map(&:to_sym)
  doorkeeper_for :create, :destroy, scopes: Settings.scopes.write.map(&:to_sym)
  doorkeeper_for :update, scopes: Settings.scopes.control.map(&:to_sym), if: -> { not physical_request }
  doorkeeper_for :privates, scopes: %w(privates).map(&:to_sym)

  before_filter :find_from_physical,      if: -> { physical_request }
  before_filter :find_owned_resources,    if: -> { not physical_request }
  before_filter :find_accessible_resources, if: -> { not physical_request }
  before_filter :find_resource,     only: %w(show update destroy privates), if: -> { not physical_request }
  before_filter :search_params,     only: %w(index)
  before_filter :search_properties, only: %w(index)
  before_filter :pagination,        only: %w(index)
  after_filter  :create_event,      only: %w(create update destroy)


  def index
    @devices = @devices.desc(:id).limit(params[:per])
    render json: @devices
  end

  def show
    render json: @device if stale?(@device)
  end

  def create
    @device = Device.new(device_params)
    @device.resource_owner_id = current_user.id
    if @device.save
      render json: @device, status: 201, location: @device.decorate.uri
    else
      render_422 'notifications.resource.not_valid', @device.errors
    end
  end

  def update
    if @device.update_attributes(device_params)
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
    resource = { id: @device.id, name: @device.name, secret: @device.secret, activation_code: @device.activation_code, uri: @device.decorate.uri }
    render json: resource, serializer: PrivateSerializer
  end


  private

  def find_from_physical
    @device = Device.find(params[:id])
    verify_secret
  end

  def find_owned_resources
    @devices = Device.where(resource_owner_id: current_user.id)
  end

  def find_accessible_resources
    # TODO there is a bug in mongoid that does not let you use the #in method
    doorkeeper_token.device_ids.each { |id| @devices = @devices.or(id: id) } if !doorkeeper_token.device_ids.empty?
  end

  def find_resource
    @device = @devices.find(params[:id])
  end

  def search_params
    @devices = @devices.where('name' => /.*#{params[:name]}.*/i) if params[:name]
    @devices = @devices.where(type: params[:type]) if params[:type]
    @devices = @devices.where(pending: params[:pending].to_bool) if params[:pending]
    @devices = @devices.in(categories: params[:categories])      if params[:categories]
  end

  # TODO see if you are able to build a query to match multiple properties.
  def search_properties(match = {})
    if params[:properties]
      match.merge!({ property_id: Moped::BSON::ObjectId(find_id(params[:properties][:uri])) }) if params[:properties][:uri]
      match.merge!({ value: params[:properties][:value] }) if params[:properties][:value]
      match.merge!({ expected: params[:properties][:expected] }) if params[:properties][:expected]
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

  def create_event
    Event.create(resource_id: @device.id, resource: 'devices', event: params[:action], data: JSON.parse(response.body), resource_owner_id: current_user.id) if @device.valid?
  end

  def device_params
    # TODO permit method is not recognized, so I can't use strong parameters
    params.delete(:properties)
    params.delete(:physical) if params[:physical].is_a? Hash
    return params
  end
end
