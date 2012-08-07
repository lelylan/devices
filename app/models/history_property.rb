class HistoryProperty
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  field :property_id
  field :value,    default: ''
  field :physical, default: ''

  attr_accessor  :uri
  attr_protected :property_id

  embedded_in :history

  validates :uri, presence: true, uri: true, on: :create
  validates :value, presence: true

  before_create :set_property_id

  private

  def set_property_id
    self.property_id = Moped::BSON::ObjectId find_id(uri)
  end
end
