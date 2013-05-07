class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  field :resource_owner_id, type: Moped::BSON::ObjectId
  field :creator_id, type: Moped::BSON::ObjectId
  field :name
  field :categories, type: Array, default: []
  field :secret
  field :type_id, type: Moped::BSON::ObjectId
  field :physical, type: Hash
  field :pending, type: Boolean, default: false
  field :activated_at, type: DateTime, default: ->{ Time.now }
  field :activation_code

  index({ resource_owner_id: 1 }, { background: true })
  index({ creator_id: 1 }, { background: true })
  index({ type_id: 1 }, { background: true })
  index({ pending: 1 }, { background: true })

  embeds_many :properties, class_name: 'DeviceProperty', cascade_callbacks: true

  attr_accessor  :type
  attr_accessible :name, :type, :categories, :physical, :properties_attributes

  validates :resource_owner_id, presence: true
  validates :creator_id,  presence: true
  validates :name, presence: true
  validates :secret, presence: true
  validates :activation_code, presence: true
  validates :type, presence: true, on: :create

  accepts_nested_attributes_for :properties

  before_create :set_type_id
  before_create :set_device_properties
  before_save   :set_pending
  before_save   :touch_locations

  before_validation(on: 'create') { set_creator_id }
  before_validation(on: 'create') { set_secret }
  before_validation(on: 'create') { set_activation_code }

  def active_model_serializer
    DeviceSerializer
  end

  def set_type_id
    self.type_id = type[:id]
  end

  def set_creator_id
    self.creator_id = resource_owner_id
  end

  def set_secret
    self.secret = Doorkeeper::OAuth::Helpers::UniqueToken.generate
  end

  def set_activation_code
    self.activation_code = Signature.sign(id, secret)
  end

  def set_device_properties
    type       = Type.find(type_id)
    properties = Property.in(id: type.property_ids)
    entries    = properties.map { |p| { property_id: p.id, value: p.default, expected: p.default } }
    self.properties_attributes = entries
    self.categories = type.categories;
  end

  def set_pending
    self.pending = properties.map(&:pending).inject(:|) || false
    return true
  end

  def touch_locations
    Location.in(device_ids: id).update_all(updated_at: Time.now) if name_changed?
  end

  def synchronize_function_properties(function, properties = [])
    self.properties_attributes = synchronized_function_properties function, properties
  end
end
