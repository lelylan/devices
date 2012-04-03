class History
  include Mongoid::Document
  include Mongoid::Timestamps

  field :device_uri
  field :created_from

  attr_accessible :device_uri, :created_from

  embeds_many :history_properties

  validates :device_uri, presence:true, url: true
  validates :created_from, presence:true, url: true


  # Create an history resource with the connected properties
  def self.create_history(params, properties)
    history     = History.new(params)
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
