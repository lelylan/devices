class ApplicationController < ActionController::API
  include Resourceable
  include Rescueable
  include Viewable
  include Eventable
  include Signable

  before_filter :deny_physical_request

  private

  def deny_physical_request
    render_401 if doorkeeper_token && doorkeeper_token.application_id == Defaults.physical_application_id
  end

  def current_user
    if doorkeeper_token
      @current_user ||= User.find(doorkeeper_token.resource_owner_id)
    end
  end
end
