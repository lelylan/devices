class PropertiesController < ApplicationController
  doorkeeper_for :update, scopes: [:write]

  before_filter :find_owned_resources
  before_filter :find_resource
  before_filter :syncrhronize

  def update
    begin
      @device.properties_attributes = @properties
      @device.pending = params[:pending] if params[:pending]
      @device.save
      create_history
      render '/devices/show'
    rescue Mongoid::Errors::DocumentNotFound => e
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
end
