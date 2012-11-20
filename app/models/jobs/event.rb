class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  store_in session: 'jobs'

  field :resource_owner_id, type: Moped::BSON::ObjectId
  field :resource_id, type: Moped::BSON::ObjectId
  #field :resource_uri
  field :resource
  field :event
  field :source
  field :data, type: Hash
  field :callback_processed, type: Boolean, default: false

  index({ resource: 1, event: 1 })

  validates :resource_owner_id, presence: true
  validates :resource_id, presence: true
  #validates :resource_uri, presence: true, uri: true
  validates :resource, presence: true
  validates :event, presence: true
  validates :data, presence: true
  validates :source, presence: true, inclusion: { in: %w(lelylan physical) }
end
