class Pending
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :uri
  field :device_uri
  field :function_uri
  field :function_name
  field :pending, type: Boolean, default: true
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
    pending.uri = Pending.base_uri(request)
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
    properties.each do |property|
      pending_property = pending_properties.where(property_uri: property[:uri]).first
      pending_property.pending = false if pending_property
    end
    if pending_properties.where(pending: true).length == 0
      self.pending = false
    end
    save
    return pending
  end

end
