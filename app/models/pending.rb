class Pending
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :uri
  field :device_uri
  field :function_uri
  field :function_name
  field :pending_status, type: Boolean, default: true
  field :expected_time, default: '0' # expected time to complete the pending funciton (in seconds)
  
  embeds_many :pending_properties
  
  validates :uri, url: true
  validates :device_uri, url: true
  validates :function_uri, url: true
  validates :function_name, presence: true

  # Create a pending resource without properties
  def self.create_pending(device, device_function, request)
    pending = Pending.new(device_uri: device.uri,
                          function_uri: device_function.function_uri,
                          function_name: device_function.name)
    pending.uri = Pending.base_uri(request, pending)
    pending.save!
    return pending
  end

  # Add pending properties
  def create_pending_properties(device, properties)
    properties.each do |property|
      self.pending_properties.create!(
        property_uri: property[:uri],
        old_value: device.device_properties.where(property_uri: property[:uri]).first.value,
        expected_value: property[:value]
      )
    end
  end
  
  # Update the pending status of updated properties
  def update_pending_properties(properties)
    properties.each { |p| update_pending_property(p) }
    self.pending_status = false if with_no_pending_properties?
    self.save!
  end

  private
    
    def update_pending_property(property)
      pending_property = pending_properties.where(property_uri: property[:uri]).first
      pending_property.pending_status = false if pending_property
    end

    def with_no_pending_properties?
      pending_properties.where(pending_status: true).length == 0
    end
end
