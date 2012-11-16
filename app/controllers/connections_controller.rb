require 'bcrypt'

class ConnectionsController < ApplicationController
  doorkeeper_for :create, scopes: Settings.scopes.write.map(&:to_sym)

  before_filter :find_owned_resources
  before_filter :find_filtered_resources
  before_filter :find_resource
  before_filter :find_physical_application
  before_filter :delete_previous_access_tokens
  before_filter :create_access_token

  def create
    render 'devices/show'
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

  def find_physical_application
    @application = Defaults.find_or_create_phisical_application
  end

  def delete_previous_access_tokens
    Doorkeeper::AccessToken
      .where(device_ids: [@device.id])
      .where(application: @application.id)
      .destroy
  end

  def create_access_token
    @token = Doorkeeper::AccessToken.create(
      resource_owner_id: current_user.id,
      application_id: @application.id,
      scope: 'devices',
      device_ids: [ @device.id ],
      expires_in: nil
    )
  end
end
