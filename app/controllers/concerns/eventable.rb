module Eventable
  extend ActiveSupport::Concern

  included do; end

  module ClassMethods
    def eventable_for(name, options)
      after_filter :create_event, only: options[:only]
      @resource      = name
      @resource_name = options[:resource]
      @event_prefix  = options[:prefix]
    end

    def resource
      @resource
    end

    def resource_name
      @resource_name
    end

    def event_prefix
      @event_prefix
    end
  end

  private

  def create_event
    Event.create(
      resource_owner_id: current_user.id,
      resource_id: resource.device_id,
      resource: self.class.resource_name,
      event: event,
      data: JSON.parse(response.body)
    )
  end

  def event(result = '')
    result += "#{self.class.event_prefix}-" if self.class.event_prefix
    result += event_action
  end

  def resource
    instance_variable_get("@#{self.class.resource}")
  end

  def event_action()
    return 'created' if params[:action] == 'create'
    return 'updated' if params[:action] == 'update'
    return 'deleted' if params[:action] == 'destroy'
  end
end
