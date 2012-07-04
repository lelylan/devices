class HistoriesController < ApplicationController
<<<<<<< HEAD
  before_filter :find_history, only: 'show'
  before_filter :find_owned_resources
  before_filter :find_resource
  before_filter :find_histories, only: 'index'
  before_filter :search_params, only: 'index'
  before_filter :pagination, only: 'index'


  def index
    @histories = @histories.limit(params[:per])
  end

  def show
  end

  private

    def find_history
      @history = History.find(params[:id])
      uri = Addressable::URI.parse(@history.device_uri)
      params[:device_id] = uri.basename
    end

=======
  before_filter :find_owned_resources
  before_filter :find_resource 
  before_filter :find_histories
  before_filter :filter_params

  def index
    @histories.page(params[:page]).per(params[:per])
  end
  
  private 
  
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
    def find_owned_resources
      @devices = Device.where(created_from: current_user.uri)
    end

    def find_resource
      @device = @devices.find(params[:device_id])
<<<<<<< HEAD
      @device = DeviceDecorator.decorate(@device)
=======
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
    end

    def find_histories
      @histories = History.where(device_uri: @device.uri)
    end
<<<<<<< HEAD

    def pagination
      params[:per] = (params[:per] || Settings.pagination.per).to_i
      if params[:start]
        uri = Addressable::URI.parse(params[:start])
        @histories = @histories.where(:_id.gt => uri.basename)
      end
    end

    def search_params
      parse_time_params
      @histories = @histories.where(:created_at.gte => Chronic.parse(params[:from])) if params[:from]
      @histories = @histories.where(:created_at.lte => Chronic.parse(params[:to]))   if params[:to]
    end

    def parse_time_params
      raise Lelylan::Errors::Time.new({key: 'from', value: params[:from]}) if (params[:from] and Chronic.parse(params[:from]) == nil)
      raise Lelylan::Errors::Time.new({key: 'to', value: params[:to]}) if (params[:to] and Chronic.parse(params[:to]) == nil)
    end
=======
    
    def filter_params
      @histories = @histories.where(:created_at.gte => Chronic.parse(params[:from])) if params[:from]
      @histories = @histories.where(:created_at.lte => Chronic.parse(params[:to]))   if params[:to]
    end
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
end
