class ConsumptionsController < ApplicationController
  doorkeeper_for :index, :show, scopes: Settings.scopes.read.map(&:to_sym)
  doorkeeper_for :create, :update, :destroy, scopes: Settings.scopes.write.map(&:to_sym)

  before_filter :find_owned_resources
  before_filter :find_resource, only: %w(show update destroy)
  before_filter :search_params, only: %w(index)
  before_filter :pagination,    only: %w(index)

  def index
    @consumptions = @consumptions.limit(params[:per])
  end

  def show
  end

  def create
    @consumption = Consumption.new(params)
    @consumption.resource_owner_id = current_user.id
    if @consumption.save!
      render 'show', status: 201, location: ConsumptionDecorator.decorate(@consumption).uri
    else
      render_422 'notifications.resource.not_valid', @consumption.errors
    end
  end

  def update
    if @consumption.update_attributes!(params)
      render 'show'
    else
      render_422 'notifications.resource.not_valid', @consumption.errors
    end
  end

  def destroy
    render 'show'
    @consumption.destroy
  end

  private

  def find_owned_resources
    @consumptions = Consumption.where(resource_owner_id: current_user.id)
  end

  def find_resource
    @consumption = @consumptions.find(params[:id])
  end

  def search_params
    @consumptions = @consumptions.where('device_id' => find_id(params[:device])) if params[:device]
    @consumptions = @consumptions.where(type: params[:type])   if params[:type]
    @consumptions = @consumptions.where(unit: params[:unit])   if params[:unit]
    @consumptions = @consumptions.gte(occur_at: params[:from]) if params[:from]
    @consumptions = @consumptions.lte(occur_at: params[:to])   if params[:to]
  end

  def pagination
    params[:per] = (params[:per] || Settings.pagination.per).to_i
    params[:per] = Settings.pagination.per if params[:per] == 0 
    params[:per] = Settings.pagination.max_per if params[:per] > Settings.pagination.max_per
    @consumptions = @consumptions.gt(id: find_id(params[:start])) if params[:start]
  end
end
