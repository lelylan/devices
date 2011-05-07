class History
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :uri
  field :device_uri

  embeds_many :history_properties

  validates :uri, presence: true, url: true
  validates :device_uri, presence:true, url: true

  # Create an history resource (with no properties)
  def self.create_history(device_uri, properties, request)
    history = create_base_history(device_uri)
    history.create_history_properties(properties)
  end

  def self.create_base_history(device_uri)
    history = History.new(device_uri: device.uri)
    history.uri = History.base_uri(request, history)
    history.save! and return history
  end

  def create_history_properties(properties)
    properties.each do |property|
      self.history_properties.create!(
        property_uri: property[:uri],
        value: property[:value]
      )
    end
  end
end
