class ApplicationController < ActionController::API
  include Resourceable
  include Rescueable
  include Viewable
  include Signable

  private

  def current_user
    @current_user ||= User.find(@device.resource_owner_id)          if request.headers['X-Physical-Signature']
    @current_user ||= User.find(doorkeeper_token.resource_owner_id) if request.headers['Authorization']
    return @current_user
  end

  def physical_request
    request.headers['X-Physical-Signature']
  end
end
