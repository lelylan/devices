#class ConsumptionsController < ApplicationController
  #before_filter :find_consumption, only: %w(show update destroy)
  #before_filter :find_owned_resources
  #before_filter :find_resource
  #before_filter :find_consumptions, only: 'index'
  #before_filter :search_params, only: 'index'
  #before_filter :pagination, only: 'index'


  #def index
    #@consumptions = @consumptions.limit(params[:per])
  #end

  #def show
  #end
  
  #def create
    #body = JSON.parse(request.body.read)
    #@consumption= Consumption.new(body)
    #@consumption.created_from = current_user.uri
    #if @consumption.save
      #render 'show', status: 201, location: ConsumptionDecorator.decorate(@consumption).uri
    #else
      #render_422 "notifications.resource.not_valid", @consumption.errors
    #end
  #end

  #def update
    #body = JSON.parse(request.body.read)
    #if @consumption.update_attributes(body)
      #render 'show'
    #else
      #render_422 'notifications.resource.not_valid', @consumption.errors
    #end
  #end

  #def destroy
    #render 'show'
    #@consumption.destroy
  #end


  #private

    #def find_consumption
      #@consumption = Consumption.find(params[:id])
      #params[:device_id] = Addressable::URI.parse(@consumption.device_uri).basename
    #end

    #def find_owned_resources
      #@devices = Device.where(created_from: current_user.uri) if params[:device_id]
    #end

    #def find_resource
      #@device = @devices.find(params[:device_id]) if params[:device_id]
      #@device = DeviceDecorator.decorate(@device) if params[:device_id]
    #end

    #def find_consumptions
      #@consumptions = Consumption.where(device_uri: @device.uri) if params[:device_id]
      #@consumptions = Consumption.where(created_from: current_user.uri) if not params[:device_id]
    #end

    #def pagination
      #params[:per] = (params[:per] || Settings.pagination.per).to_i
      #uri = Addressable::URI.parse(params[:start]) if params[:start]
      #@consumptions = @consumptions.where(:_id.gt => uri.basename) if params[:start]
    #end

    #def search_params
      #parse_time_params
      #@consumptions = @consumptions.where(type: params[:type]) if params[:type]
      #@consumptions = @consumptions.where(unit: params[:unit]) if params[:unit]
      #@consumptions = @consumptions.where(:occur_at.gte => Chronic.parse(params[:from])) if params[:from]
      #@consumptions = @consumptions.where(:occur_at.lte => Chronic.parse(params[:to])) if params[:to]
    #end

    #def parse_time_params
      #raise Lelylan::Errors::Time.new({key: 'from', value: params[:from]}) if (params[:from] and Chronic.parse(params[:from]) == nil)
      #raise Lelylan::Errors::Time.new({key: 'to', value: params[:to]}) if (params[:to] and Chronic.parse(params[:to]) == nil)
    #end
#end
