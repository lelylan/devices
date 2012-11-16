class AccessesController < ApplicationController
  doorkeeper_for :create, scopes: Settings.scopes.write.map(&:to_sym)

  before_filter :find_owned_resources
  before_filter :find_filtered_resources
  before_filter :find_resource
  before_filter :find_physical
  before_filter :find_physical_application
  before_filter :delete_previous_access_tokens
  before_filter :create_access_token

  def create
    url     = "#{@device.physical}"
    body    = { uri: device_url(@device), access_token: @token.token, nonce: SecureRandom.uuid }
    headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json',
                'X-Physical-Signature' => Signature.sign(body, @device.secret) }

    response = Faraday.new(url: url).post do |req|
      req.url     '/physicals'
      req.headers = headers
      req.body    = body
    end

    response.status == 200 ? render_success : render_failure
  end

  private

  def find_owned_resources
    @devices = Device.where(resource_owner_id: current_user.id)
  end

  def find_filtered_resources
    doorkeeper_token.device_ids.each {|id| @devices = @devices.or(id: id) } if not doorkeeper_token.device_ids.empty?
  end

  def find_resource
    @device = @devices.find(params[:id])
  end

  def find_physical
    error = 'notifications.physical.missing'
    render_422(error, I18n.t(error)) if not @device.physical
  end

  def find_physical_application
    @application = Defaults.find_or_create_phisical_application
  end

  def delete_previous_access_tokens
    Doorkeeper::AccessToken.where(device_ids: [@device.id]).where(application: @application.id).destroy
  end

  def create_access_token
    @token = Doorkeeper::AccessToken.create(
      resource_owner_id: current_user.id,
      application_id: @application.id,
      scopes: 'devices',
      device_ids: [ @device.id ],
      expires_in: nil)
  end

  # view rendering methods

  def render_success
      render 'devices/show'
  end

  def render_failure
    error = 'notifications.physical.failed'
    render_422 error, I18n.t(error)
  end
end
