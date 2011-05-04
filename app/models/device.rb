class Device
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri
  field :created_from
  field :name
  field :type_uri
  field :type_name

  embeds_many :device_properties  # device properties (inherited from type)
  embeds_many :device_functions   # device functions (inherited from type)
  embeds_many :device_physicals   # physical devices to control
  embeds_many :device_locations   # locations the device is contained in

  validates :uri, url: true
  validates :created_from, url: true
  validates :name, presence: true
  validates :type_uri, presence: true, url: true
  validates :type_name, presence: true

  # Inherit properties and functions from the selected type
  def sync_type(uri)
  end

  private

    # Sync properties
    def sync_properties
    end

    # Sync functions
    def sync_functions
    end
end
