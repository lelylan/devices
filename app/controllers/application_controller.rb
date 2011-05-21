class ApplicationController < ActionController::Base
  include Lelylan::Rescue::Helpers
  include Lelylan::View::Helpers
  include Lelylan::Resources::Public
  include Lelylan::Pagination::Helpers

  protect_from_forgery
  before_filter :authenticate
  before_filter :paginate, only: 'index'

  helper_method :json_body
  helper_method :current_user
  helper_method :admin_does_not_exist
  
  private

    # JSON body parsing
    def parse_json_body
      @json_body = HashWithIndifferentAccess.new(JSON.parse(request.body.read.to_s))
    end

    def json_body
      @json_body
    end


    # Authentication system
    def authenticate
      api_request ? basic_auth : session_auth
    end

    # Check the API format
    def api_request
      request.format == "application/json"
    end

    # Apply the basic authentication for API requests
    def basic_auth
      authenticate_or_request_with_http_basic do |username, password|
        user = User.where(email: username).first
        if user and user.verify(password)
          @current_user = user
        else
          allow_public_resources('types')
        end
      end
    end

    # Apply the session authentication for web pages requests
    def session_auth
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
      unless current_user
        redirect_to(log_in_path) and return false
      end
    end

    def admin_does_not_exist
      User.where(admin: true).first.nil?
    end
    
    def current_user
      @current_user
    end



end
