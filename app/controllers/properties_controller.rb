class PropertiesController < ApplicationController
  rescue_from    Mongoid::Errors::DocumentNotFound, with: :document_not_found
  doorkeeper_for :update, scopes: Settings.scopes.control.map(&:to_sym)

  skip_before_filter :deny_physical_request

  before_filter :find_owned_resources
  before_filter :find_filtered_resources
  before_filter :find_resource
  before_filter :verify_signature

  eventable_for 'device', resource: 'devices', prefix: 'property', only: %w(update)

  def update
    @device.properties_attributes = properties_attributes
    @device.update_attributes(pending: params[:pending]) if params[:pending]
    create_history
    render json: @device, status: status_code
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

  def create_history
    @device = DeviceDecorator.decorate @device
    History.create device: @device.uri, properties: params[:properties] do |history|
      history.resource_owner_id = current_user.id
    end
  end

  def status_code
    @source = params[:source] || request.headers['X-Request-Source']
    @source = 'physical' if doorkeeper_token.application_id == Defaults.physical_application_id
    forward_to_physical = (@device.physical and @source != 'physical')
    forward_to_physical ? 202 : 200
  end

  # extras

  def properties_attributes
    params_properties
  end

  def params_properties
    params[:properties].tap { |p| p.map { |p| p[:id] = find_id p[:uri] } }
  end

  def document_not_found(e)
    params[:properties] ||= []
    render_404 'notifications.resource.not_found', request.url if not @device
    render_404 'notifications.property.not_found', params[:properties].map { |p| p[:uri] } if @device
  end
end
