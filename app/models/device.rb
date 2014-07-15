class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  field :resource_owner_id, type: Moped::BSON::ObjectId
  field :maker_id, type: Moped::BSON::ObjectId
  field :name
  field :category
  field :secret
  field :type_id, type: Moped::BSON::ObjectId
  field :physical, type: Hash
  field :pending, type: Boolean, default: false
  field :activated_at, type: DateTime, default: ->{ Time.now }
  field :activation_code
  field :updated_from

  index({ resource_owner_id: 1 }, { background: true })
  index({ maker_id: 1 }, { background: true })
  index({ type_id: 1 }, { background: true })
  index({ pending: 1 }, { background: true })

  embeds_many :properties, class_name: 'DeviceProperty', cascade_callbacks: true

  attr_accessor :type
  attr_accessible :name, :type, :category, :updated_from, :physical, :properties_attributes

  validates :resource_owner_id, presence: true
  validates :maker_id,  presence: true
  validates :name, presence: true
  validates :secret, presence: true
  validates :activation_code, presence: true
  validates :type, presence: true, on: :create

  accepts_nested_attributes_for :properties

  before_create :set_type_id
  before_create :set_device_properties
  before_save   :set_physical
  before_save   :set_pending
  before_save   :touch_locations

  before_validation(on: 'create') { set_maker_id }
  before_validation(on: 'create') { set_secret }
  before_validation(on: 'create') { set_activation_code }

  def active_model_serializer
    DeviceSerializer
  end

  def set_type_id
    self.type_id = type[:id]
  end

  def set_maker_id
    self.maker_id = resource_owner_id
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
    self.category = type.category;
  end

  def set_physical
    self.physical = nil if physical and physical['uri'].blank?
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
