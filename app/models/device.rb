class Device
  include Mongoid::Document
  include Mongoid::Timestamps
  include Resourceable

  field :resource_owner_id, type: Moped::BSON::ObjectId
  field :name
  field :type_id, type: Moped::BSON::ObjectId
  field :pending, type: Boolean, default: false

  attr_accessor  :type
  attr_protected :resource_owner_id, :type_id

  embeds_many :properties, class_name: 'DeviceProperty', cascade_callbacks: true
  embeds_one  :physical,   class_name: 'DevicePhysical', cascade_callbacks: true

  validates :resource_owner_id, presence: true
  validates :name, presence: true
  validates :type, presence: true, uri: true, on: :create

  accepts_nested_attributes_for :properties, allow_destroy: true

  before_create :set_type_uri, :synchronize_type_properties

  def set_type_uri
    self.type_id = find_id type
  end

  # Cache with auto-expiring key composed by device created_at and type updated_at.
  def synchronize_type_properties
    self.properties_attributes = synchronized_type_properties
  end

  private

  def synchronized_type_properties
    type = Type.find(type_id)
    (add_properties(type) + remove_properties(type)).flatten
  end

  def add_properties(type)
    properties = Property.in(id: new_properties(type))
    properties.map{ |p| { property_id: p.id, value: p.default } }
  end

  def remove_properties(type)
    properties = old_properties(type)
    properties.map{ |p| { id: p, _destroy: '1' } }
  end

  def new_properties(type)
    [ type.property_ids - properties.map(&:id) ].flatten
  end

  def old_properties(type)
    [ properties.map(&:id) - type.property_ids ].flatten
  end
end
