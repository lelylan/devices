class FunctionsController < ApplicationController
  rescue_from Mongoid::Errors::DocumentNotFound, with: :document_not_found

  doorkeeper_for :update, scopes: Settings.scopes.control.map(&:to_sym), if: -> { not physical_request }

  before_filter :find_from_physical,      if: -> { physical_request }
  before_filter :find_owned_resources,    if: -> { not physical_request }
  before_filter :find_filtered_resources, if: -> { not physical_request }
  before_filter :find_resource,           if: -> { not physical_request }
  before_filter :create_physical_request
  after_filter  :create_event

  def update
    @device.update_attributes(properties_attributes: properties_attributes)
    create_history
    render json: @device, status: status_code
  end


  private

  def find_from_physical
    @device = Device.find(params[:id])
    verify_signature
  end

  def find_owned_resources
    @devices = Device.where(resource_owner_id: current_user.id)
  end

  def find_filtered_resources
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
      properties = properties_attributes.tap { |p| p.map { |p| p[:value] = p[:expected_value] unless p[:value] } }
      Physical.create(resource_id: @device.id, data: { properties: properties })
    end
  end

  def create_history
    @device = DeviceDecorator.decorate @device
    History.create device: @device.uri, properties: @device.properties do |history|
      history.resource_owner_id = current_user.id
    end
  end

  def create_event
    Event.create(resource_id: @device.id, resource: 'histories', event: 'create', data: JSON.parse(response.body), resource_owner_id: current_user.id) if @device.valid?
  end


  # Properties normalization

  def properties_attributes
    @properties_attributes ||= merge_properties(params[:function], params_properties)
  end

  def merge_properties(function, params_properties)
    @function = Function.find(find_id function)
    override_ids = params_properties.map { |p| p[:id] }
    function_properties = @function.properties.nin(property_id: override_ids)
    function_properties = function_properties.map { |p|  DevicePropertyDecorator.decorate(p) }
    function_properties = function_properties.map { |p| { uri: p.uri, id: p.property_id.to_s, value: p.value } }
    (function_properties + params_properties).flatten
  end

  def params_properties
    params[:properties] ||= []
    params[:properties].tap { |p| p.map { |p| p[:id] = find_id p[:uri] } }
  end

  def document_not_found(e)
    params[:properties] ||= []
    return render_404 'notifications.resource.not_found', request.url if !@device
    return render_404 'notifications.function.not_found', request.url if !@function
    return render_404 'notifications.property.not_found', params[:properties].map { |p| p[:uri] } if @device
  end
end
