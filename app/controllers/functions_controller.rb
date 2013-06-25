class FunctionsController < ApplicationController
  rescue_from Mongoid::Errors::DocumentNotFound, with: :document_not_found

  doorkeeper_for :update, scopes: Settings.scopes.control.map(&:to_sym), if: -> { not physical_request }

  before_filter :find_from_physical,        if: -> { physical_request }
  before_filter :find_owned_resources,      if: -> { not physical_request }
  before_filter :find_accessible_resources, if: -> { not physical_request }
  before_filter :find_resource,             if: -> { not physical_request }
  before_filter :create_physical_request
  before_filter :updated_from
  after_filter  :create_event
  after_filter  :create_history

  def update
    @device.update_attributes(properties_attributes: properties_attributes, updated_at: Time.now, updated_from: params[:updated_from])
    render json: @device, status: status_code
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
    # TODO there is a bag in mongoid that does not let you use the #in method
    doorkeeper_token.device_ids.each { |id| @devices = @devices.or(id: id) } if !doorkeeper_token.device_ids.empty?
  end

  def find_resource
    @device = @devices.find(params[:id])
  end

  def status_code
    (!physical_request and @device.physical) ? 202 : 200
  end

  def create_physical_request
    if (!physical_request and @device.physical)
      Physical.create(resource_id: @device.id, data: { properties: physical_properties })
    end
  end

  def updated_from
    if not params[:updated_from]
      params[:updated_from] = physical_request ? 'physical' : current_user.description
    end
  end

  def create_event
    if @device.valid?
      token = doorkeeper_token ? doorkeeper_token.token : nil
      Event.create(resource_id: @device.id, resource: 'devices', event: 'property-update', data: JSON.parse(response.body), resource_owner_id: current_user.id, token: token)
    end
  end

  def create_history
    @device = DeviceDecorator.decorate @device
    source  = physical_request ? 'physical' : 'lelylan'
    History.create(device: @device.uri, properties: @device.properties, source: source) do |history|
      history.resource_owner_id = current_user.id
    end
  end


  # Properties normalization

  def properties_attributes
    @properties_attributes ||= merge_properties(params[:function], params_properties) || []
  end

  def merge_properties(function, params_properties)
    if function
      @function = Function.find(function[:id])
      override_ids = params_properties.map { |p| p[:id] }
      function_properties = @function.properties.nin(property_id: override_ids)
      function_properties = function_properties.map { |p|  DevicePropertyDecorator.decorate(p) }
      function_properties = function_properties.map { |p| { id: p.property_id.to_s, uri: p.uri, expected: p.value, pending: true } }
      params_properties   = params_properties.each  { |p| p[:pending] = true }
      return (function_properties + params_properties).flatten
    end
  end

  def params_properties
    params[:properties] ||= []
    params[:properties].tap { |p| p.map { |p| p[:id] = p[:id] } }
  end

  def physical_properties
    properties_attributes.map do |p|
      { id: p[:id], value: p[:value] || p[:expected] }
    end
  end

  def document_not_found(e)
    params[:properties] ||= []
    return render_404 'notifications.resource.not_found', request.url if !@device
    return render_404 'notifications.function.not_found', request.url if !@function
    return render_404 'notifications.property.not_found', params[:properties].map { |p| p[:uri] } if @device
  end
end
