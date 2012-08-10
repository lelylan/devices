class PhysicalsController < ApplicationController
  doorkeeper_for :update, :destroy, scopes: [:write]

  before_filter :find_owned_resources
  before_filter :find_resource, only: %w(update destroy)

  def update
    if @device.update_attributes!(params)
      render 'devices/show'
    else
      render_422 'notifications.resource.not_valid', @device.errors
    end
  end

  def destroy
    @device.update_attributes(physical: nil)
    render 'devices/show'
  end

  private

  def find_owned_resources
    @devices = Device.where(resource_owner_id: current_user.id)
  end

  def find_resource
    @device = @devices.find(params[:id])
  end
end
