class DeviceSerializer < ApplicationSerializer
  cached true

  attributes :uri, :id, :name, :type, :categories, :physical, :pending, :activated,
    :properties, :owner, :maker, :created_at, :updated_at, :updated_from

  def uri
    object.decorate.uri
  end

  def type
    { id: object.type_id, uri: object.decorate.type_uri }
  end

  def properties
    object.properties.map do |property|
      property = property.decorate
      { uri: property.uri, id: property.id, value: property.value, expected: property.expected, pending: property.pending, accepted: property.accepted }
    end
  end

  def activated
    object.activated_at ? true : false
  end

  def owner
    { id: object.resource_owner_id, uri: object.decorate.owner_uri }
  end

  def maker
    { id: object.maker_id, uri: object.decorate.maker_uri }
  end
end
