class History
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :uri
  field :device_uri

  embeds_many :history_properties

  validates :uri, presence: true, url: true
  validates :device_uri, presence:true, url: true


  def self.create_history(device_uri, properties, request)
    history = create_base_history(device_uri, request)
    history.create_history_properties(properties)
    return history
  end

  def self.create_base_history(device_uri, request)
    history = History.new(device_uri: device_uri)
    history.uri = History.base_uri(request, history)
    history.save! and return history
  end

  def create_history_properties(properties)
    properties.each do |property|
      self.history_properties.create!(
        uri: property[:uri],
        value: property[:value])
    end
  end
end
