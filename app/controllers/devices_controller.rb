class DevicesController < ApplicationController
  before_filter :find_owned_resources
  before_filter :search_params, only: 'index'

  def index
    @devices = @devices.page(params[:page]).per(params[:per])
  end


  private

    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def search_params
      @devices = @devices.where('name' => /^#{params[:name]}/) if params[:name]
      @devices = @devices.where(type_uri: params[:type]) if params[:type_uri]
      @devices = @devices.any_in('device_properties.uri' => [params[:property]]) if params[:property_uri]
      @devices = @devices.where('device_properties.value' => params[:property_value]) if params[:property_value]
    end 
end
