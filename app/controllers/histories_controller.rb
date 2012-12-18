class HistoriesController < ApplicationController
  doorkeeper_for :index, :show, scopes: Settings.scopes.read.map(&:to_sym)

  before_filter :find_owned_resources
  before_filter :find_filtered_resources
  before_filter :find_resource,     only: %w(show)
  before_filter :search_params,     only: %w(index)
  before_filter :search_properties, only: %w(index)
  before_filter :pagination,        only: %w(index)

  def index
    @histories = @histories.limit(params[:per])
    render json: @histories
  end

  def show
    render json: @history if stale?(@history)
  end

  private

  def find_owned_resources
    @histories = History.where(resource_owner_id: current_user.id)
  end

  def find_filtered_resources
    @histories = @histories.in(device_id: doorkeeper_token.device_ids) if not doorkeeper_token.device_ids.empty?
  end

  def find_resource
    @history = @histories.find(params[:id])
  end

  def search_params
    @histories = @histories.where(device_id: find_id(params[:device])) if params[:device]
    @histories = @histories.where(source: find_id(params[:source]))    if params[:source]
    @histories = @histories.gte(created_at: params[:from]) if params[:from]
    @histories = @histories.lte(created_at: params[:to])   if params[:to]
  end

  def search_properties(match = {})
    if params[:properties]
      match.merge!({ property_id: Moped::BSON::ObjectId(find_id(params[:properties][:uri])) }) if params[:properties][:uri]
      match.merge!({ value: params[:properties][:value] }) if params[:properties][:value]
      match.merge!({ expected_value: params[:properties][:expected_value] }) if params[:properties][:expected_value]
      match.merge!({ pending: params[:properties][:pending].to_bool }) if params[:properties][:pending]
      @histories = @histories.where('properties' => { '$elemMatch' => match })
    end
  end

  def pagination
    params[:per] = (params[:per] || Settings.pagination.per).to_i
    params[:per] = Settings.pagination.per if params[:per] == 0
    params[:per] = Settings.pagination.max_per if params[:per] > Settings.pagination.max_per
    @histories = @histories.gt(id: find_id(params[:start])) if params[:start]
  end
end
