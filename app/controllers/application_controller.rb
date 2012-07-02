class ApplicationController < ActionController::Base
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

    # Override the 401 notification method
    ActionController::HttpAuthentication::Basic.module_eval do
      def authentication_request(controller, realm)
        controller.render_401
      end
    end
end
