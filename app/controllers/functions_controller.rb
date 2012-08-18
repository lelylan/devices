class FunctionsController < ApplicationController
  doorkeeper_for :update, scopes: %w(devices resources).map(&:to_sym)

  before_filter :find_owned_resources
  before_filter :find_resource
  before_filter :syncrhronize
  before_filter :status_code

  def update
    begin
      @device.synchronize_function_properties params[:function], @properties
      @device.pending = params[:pending] if params[:pending]
      @device.save
      create_history
      render '/devices/show', status: @status_code
    rescue Mongoid::Errors::DocumentNotFound => e
      params[:properties] ||= []
      render_404 'notifications.resource.not_found', params[:properties].map {|p| p[:uri]}
    end
  end

  private 

  def find_owned_resources
    @devices = Device.where(resource_owner_id: current_user.id)
  end

  def find_resource
    @device = @devices.find(params[:id])
  end

  def syncrhronize
    @device.synchronize_type_properties
    @properties = @device.device_properties params[:properties]
  end

  def create_history
    @device = DeviceDecorator.decorate @device
    History.create device: @device.uri, properties: params[:properties] do |history|
      history.resource_owner_id = current_user.id
    end
  end

  def status_code
    @status_code = @device.physical ? 202 : 200
  end
end
