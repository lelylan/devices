class History
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  field :resource_owner_id, type: Moped::BSON::ObjectId
  field :device_id, type: Moped::BSON::ObjectId

  attr_accessor  :device
  attr_protected :device_id, :resource_owner_id

  embeds_many :properties, class_name: 'HistoryProperty', cascade_callbacks: true

  validates :resource_owner_id, presence:true
  validates :device, presence: true, uri: true, on: :create

  before_create :set_device_id

  private

  def set_device_id
    self.device_id = Moped::BSON::ObjectId find_id(device)
  end
end
