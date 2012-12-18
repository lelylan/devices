class History
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  field :resource_owner_id, type: Moped::BSON::ObjectId
  field :device_id, type: Moped::BSON::ObjectId
  field :source, default: 'lelylan'

  index({ resource_owner_id: 1 }, { background: true })
  index({ device_id: 1 }, { background: true })
  index({ created_at: 1 }, { background: true })

  attr_accessor  :device
  attr_protected :device_id, :resource_owner_id

  embeds_many :properties, class_name: 'HistoryProperty', cascade_callbacks: true

  validates :resource_owner_id, presence:true
  validates :device, presence: true, uri: true, on: :create
  validates :source, inclusion: %w(lelylan physical)

  before_create :set_device_id

  # TODO: seems a bug, as the serializer should be automatically found
  def active_model_serializer; HistorySerializer; end

  private

  def set_device_id
    self.device_id = Moped::BSON::ObjectId find_id(device)
  end
end
