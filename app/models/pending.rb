class Pending
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :uri
  field :device_uri
  field :pending_status, type: Boolean, default: true
  field :expected_time, default: '0'
  
  embeds_many :pending_properties
  
  validates :uri, presence: true, url: true
  validates :device_uri, presence: true, url: true
  validates :pending_status, inclusion: {in: [true, false]}


  # -----------------
  # Pending creation
  # -----------------
  
  # Create a pending resource without properties
  def self.create_pending(device, device_function, request)
    pending = Pending.new(
      device_uri: device.uri,
      function_uri: device_function.uri,
      function_name: device_function.name)
    pending.uri = Pending.base_uri(request, pending)
    pending.save!
    return pending
  end

  # Add pending properties
  def create_pending_properties(device, properties)
    properties.each do |property|
      self.pending_properties.create!(
        uri: property[:uri],
        value: property[:value],
        old_value: device.device_properties.where(uri: property[:uri]).first.value
      )
    end
  end
  
  # ----------------
  # Pending Update
  # ----------------

  # Update all the pending status of all pending resources related
  # to a specific device
  def self.close_pendings(device_uri, properties)
    pendings = open_pendings_for(device_uri)
    pendings.each { |p| p.update_pending_properties(properties) }
  end

  # Update the pending properties of a pending resource
  def update_pending_properties(properties)
    properties.each { |p| update_pending_property(p) }
    self.pending_status = false if with_no_pending_properties?
    self.save!
  end

  # Returns a list of all open pending resources related to a device
  def self.open_pendings_for(device_uri)
    self.where(device_uri: device_uri).and(pending_status: true)
  end


  private

    # Update the property related to a pending resource. If the received value
    # is not the final one, the property value remain pending and the value is 
    # pushed into the transitional_values array
    def update_pending_property(property)
      pending_property = find_open_pending_property(property[:uri])
      if (pending_property)
        if (pending_property.value == property[:value])
          pending_property.pending_status = false
        else
          pending_property.transitional_values << property[:value]
        end
      end
    end

    # Returns true if all properties have pending value false
    def with_no_pending_properties?
      pending_properties.where(pending_status: true).length == 0
    end
    
    # Returns the pending property if still open
    def find_open_pending_property(uri)
      pending_properties.where(uri: uri, pending_status: true).first
    end
end
