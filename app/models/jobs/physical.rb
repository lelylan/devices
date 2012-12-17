class Physical
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  store_in session: 'jobs'

  field :data, type: Hash
  field :physical_processed, type: Boolean, default: false

  validates :data, presence: true
end
