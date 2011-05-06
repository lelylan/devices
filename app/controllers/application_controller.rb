class ApplicationController < ActionController::Base
  include Lelylan::Rescue::Helpers
  include Lelylan::View::Helpers

  protect_from_forgery
  before_filter :authenticate
  before_filter :set_pagination, only: 'index'

  helper_method :json_body
  helper_method :current_user
  helper_method :admin_does_not_exist
  
  private

    # JSON body parsing
    def parse_json_body
      @json_body = HashWithIndifferentAccess.new(JSON.parse(request.body.read.to_s))
      # TODO: if nil raise an error
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
          false
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


    def set_pagination
      page, per = normalize_pagination_params
      if (page != params[:page] or per != params[:per])
        redirect_to action: :index, page: page, per: per and return
      end
      paginate_navigation
    end

    def normalize_pagination_params
      page = params[:page] ? params[:page] : Settings.pagination.page
      per = params[:per] ? params[:per] : Settings.pagination.per
      if (per == "all")
        page = Settings.pagination.page
        per = resources_count
      end
      [page, per]
    end

    def resources_count
      klass = model_klass
      klass.where(created_from: current_user.uri).count
    end

    def model_klass
      self.class.to_s.gsub("Controller", "").singularize.constantize
    end


    def paginate_navigation
      @last_uri  = page_url_for(last_page)
      @next_uri  = page_url_for(next_page(@last_page))
      @prev_uri  = page_url_for(prev_page(@last_page))
      @first_uri = page_url_for(first_page)
    end

    def last_page
      last = resources_count / params[:per].to_f
      last = Settings.pagination.page if last == 0
      @last_page = last.ceil.to_s
    end

    def next_page(last)
      nexty = params[:page].to_i + 1
      page = (nexty <= last.to_i) ? nexty.to_s : last
    end

    def prev_page(last)
      previous = params[:page].to_i - 1
      page = (previous > 1) ? previous.to_s : Settings.pagination.page
      page = (previous > last.to_i) ? last : page
    end

    def first_page
      Settings.pagination.page
    end

    def page_url_for(page)
      "#{request.protocol}#{request.host_with_port}/#{model_klass.to_s.downcase.pluralize}?page=#{page}&per=#{params[:per]}"
    end

end
