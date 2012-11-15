class PropertiesController < ApplicationController

  doorkeeper_for :update, scopes: Settings.scopes.write.map(&:to_sym)

  before_filter :find_owned_resources
  before_filter :find_filtered_resources
  before_filter :find_resource
  before_filter :verify_signature
  before_filter :syncrhronize
  before_filter :status_code

  eventable_for 'device', resource: 'devices', prefix: 'property', only: %w(update)

  def update
    begin
      @device.properties_attributes = @properties
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

  def verify_signature
    source = params[:source] || request.headers['X-Request-Source']
    # the request must come from the physical device and in a not secure channel
    if source == 'physical' and not request.ssl?
      # get the article id
      article_id = Moped::BSON::ObjectId(find_id(@device.physical.uri))
      # find the product
      product = Product.where('articles._id' => article_id).first
      # get the signature
      signature  = request.headers['X-Physical-Signature']
      # remove a key that is automatically added by rails
      payload = request.request_parameters.delete_if {|k, v| k == 'property' }
      # unauthorize if the physical id does not exist
      render_401 if not product
      # unauthorize if the signature is not valid
      render_401 if not Signature.valid?(signature, payload, product.secret)
    end
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
    source = params[:source] || request.headers['X-Request-Source']
    forward_to_physical = (@device.physical and source != 'physical')
    @status_code = forward_to_physical ? 202 : 200
  end
end
