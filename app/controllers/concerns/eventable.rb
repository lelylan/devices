#
# Lets your actions create an Event when called.
# You can set the following options
#
# - name: instance variable used to take the resource id
# - options:
#   - resource: string value saved in the :resource event field
#   - prefix: string value that prefix the event name
#   - resource_id (default to 'id'): field where the resource id is stored
#   - only: actions generating the event
#
# Examples:
#
#   eventable_for :subscription, resource: 'devices', prefix: 'consumption', resource_id: 'device_id', only: %w(create)
#

module Eventable
  extend ActiveSupport::Concern

  included do; end

  module ClassMethods

    attr_accessor :resource, :resource_name, :resource_id, :event_prefix

    def eventable_for(name, options)
      after_filter :create_event, only: options[:only]

      @resource      = name.to_s
      @resource_name = options[:resource]
      @event_prefix  = options[:prefix]
      @resource_id   = options[:resource_id] || 'id'
    end
  end

  private

  def create_event
    if resource.valid?
      Event.create(
        resource_owner_id: current_user.id,
        resource_id: resource.send(self.class.resource_id),
        resource: self.class.resource_name,
        event: event, source: source, data: data)
    end
  end

  def data
    return JSON.parse(response.body)                         if event != 'property-updated'
    return { properties: self.send(:properties_attributes) } if event == 'property-updated'
  end

  def source
    instance_variable_get('@source') || 'lelylan'
  end

  def event(result = '')
    result += "#{self.class.event_prefix}-" if self.class.event_prefix
    result += event_action
  end

  def resource
    instance_variable_get("@#{self.class.resource}")
  end

  def resource_id
     resource.device_id || resource.id
  end

  def event_action
    return 'created' if params[:action] == 'create'
    return 'updated' if params[:action] == 'update'
    return 'deleted' if params[:action] == 'destroy'
  end
end
