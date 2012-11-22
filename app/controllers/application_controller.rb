class ApplicationController < ActionController::Base
  include Resourceable
  include Rescueable
  include Viewable
  include Eventable
  include Signable

  before_filter :deny_physical_request

  private

  def deny_physical_request
    pp "::::::: HELO THERE ::::::", Defaults.physical_application_id, Defaults.user_application_id
    render_401 if doorkeeper_token.application_id == Defaults.physical_application_id
  end

  def current_user
    if doorkeeper_token
      @current_user ||= User.find(doorkeeper_token.resource_owner_id)
    end
  end
end
