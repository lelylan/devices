class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  store_in session: 'jobs'

  field :resource_owner_id, type: Moped::BSON::ObjectId
  field :resource_id, type: Moped::BSON::ObjectId
  field :resource
  field :event
  field :data, type: Hash

  index({ resource: 1, event: 1 })

  validates :resource_owner_id, presence: true
  validates :resource_id, presence: true
  validates :resource, presence: true
  validates :event, presence: true
  validates :data, presence: true
end
