class History
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :uri
  field :device_uri

  embeds_many :history_properties

  validates :uri, presence: true, url: true
  validates :device_uri, presence:true, url: true


  # Create an history resource with the connected properties
  # We do not use History.base method because we do not care
  # about the user who create this.
  def self.create_history(params, properties, request)
    history     = History.new(params)
    history.uri = History.base_uri(request, history)
    history.create_properties(properties)
    history.save! and return history
  end

  # Add properties to the history resource
  def create_properties(properties)
    properties.each do |property|
      self.history_properties.create!(
        uri: property[:uri],
        value: property[:value])
    end
  end
end
