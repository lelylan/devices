class ApplicationController < ActionController::Base
<<<<<<< HEAD
  include Lelylan::Errors::Helpers        # JSON error views
  include Lelylan::Resources::Public      # public resources

  protect_from_forgery

  before_filter :authenticate

  helper_method :current_user

  private

    # ---------------------
    # Authentication flow
    # ---------------------

    # TODO: Lelylan::People.auth(username: username, password: password, flow: 'basic')
    # should substitute the authentication_user method
    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        response = authenticate_user(username, password)
        if response.code == 200
          @current_user = Hashie::Mash.new JSON.parse(response.body)
        else
          @current_user = nil
          #allow_public_resources([])
        end
      end
    end

    # Remote authentication
    def authenticate_user(username, password)
      options = { body: { username: username, password: password }.to_json, 
                  headers: { 'Content-Type' => 'application/json', 'Accept'=>'application/json' } }
      HTTParty.post 'https://people.lelylan.com/authentication', options
    end

    # Helper method to get user information
    def current_user
      @current_user
    end


    # ---------------------
    # Not authorized JSON
    # ---------------------
=======
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
      json_request? or exception_request?
    end

    def json_request?
      request.format == "application/json"
    end

    def exception_request?
      (request.format == "image/png" and params[:controller] == 'statuses') 
    end

    # Apply the basic authentication for API requests
    def basic_auth
      authenticate_or_request_with_http_basic do |username, password|
        user = User.where(email: username).first
        if user and user.verify(password)
          @current_user = user
        else
          allow_public_resources([])
        end
      end
    end
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750

    # Override the 401 notification method
    ActionController::HttpAuthentication::Basic.module_eval do
      def authentication_request(controller, realm)
        controller.render_401
      end
    end
<<<<<<< HEAD
=======

    # Apply the session authentication for web pages requests
    def session_auth
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
      unless current_user
        pp params
        redirect_to(log_in_path) and return false
      end
    end

    def admin_does_not_exist
      User.where(admin: true).first.nil?
    end
    
    def current_user
      @current_user
    end



>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
end
