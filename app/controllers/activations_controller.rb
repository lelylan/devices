class ActivationsController < ApplicationController
  rescue_from Mongoid::Errors::DocumentNotFound, with: :document_not_found

  doorkeeper_for :create, :destroy, scopes: Settings.scopes.control.map(&:to_sym)

  before_filter :find_all_resources, only: %w(create)
  before_filter :find_owned_resources, only: %w(destroy)
  before_filter :find_filtered_resources, only: %w(destroy)
  before_filter :find_resource_by_activation_code
  before_filter :already_activated, only: %w(create)

  def create
    @device.activated_at = Time.now
    @device.resource_owner_id = current_user.id
    if @device.save
      render json: @device, status: 201, location: DeviceDecorator.decorate(@device).uri
    else
      render_422 'notifications.resource.not_valid', @device.errors
    end
  end

  def destroy
    @device.activated_at = nil
    @device.save
    render json: @device
  end

  private

  def find_all_resources
    @devices = Device.all
  end

  def find_owned_resources
    @devices = Device.where(resource_owner_id: current_user.id)
  end

  def find_filtered_resources
    # TODO solution that temporarly solve the bug that should let you use
    #@devices.in(id: doorkeeper_token.device_ids) if not doorkeeper_token.device_ids.empty?
    if not doorkeeper_token.device_ids.empty?
      doorkeeper_token.device_ids.each {|id| @devices = @devices.or(id: id) }
    end
  end

  def find_resource_by_activation_code
    @device = @devices.find_by(activation_code: params[:activation_code] || params[:id])
  end

  def already_activated
    error   = 'notifications.resource.already_activated'
    message = "#{I18n.t(error)} by user #{@device.resource_owner_id}"
    render_422(error, message) if @device.activated_at
  end

  def document_not_found
    render_404 'notifications.activation.not_found' if params[:action] == 'create'
    render_404 'notifications.resource.not_found' if params[:action] == 'destroy'
  end
end
