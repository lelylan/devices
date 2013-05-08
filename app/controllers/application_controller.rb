class ApplicationController < ActionController::API
  include Resourceable
  include Rescueable

  private

  def current_user
    @current_user ||= User.find(@device.resource_owner_id)          if request.headers['X-Physical-Secret']
    @current_user ||= User.find(doorkeeper_token.resource_owner_id) if request.headers['Authorization']
    return @current_user
  end

  def physical_request
    request.headers['X-Physical-Secret']
  end

  def verify_secret
    if request.headers['X-Physical-Secret']
      secret = request.headers['X-Physical-Secret']
      render_401 if @device and @device.secret != secret
    end
  end
end
