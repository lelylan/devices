class FunctionsController < ApplicationController
  before_filter :parse_json_body
  before_filter :find_owned_resources
  before_filter :find_resource 
  before_filter :find_function
  before_filter :find_function_uri

  def update
    head 200
  end
  
  private 
  
    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:device_id])
    end

    # TODO: think if the URI is correct or not in this way
    def find_function
      @device_function = @device.device_functions.where(uri: request.url).first
      unless @device_function
        render_404 "notifications.document.not_found", {uri: request.url}
      end
    end

    def find_function_uri
      @function_uri = @device_function.function_uri
    end
end
