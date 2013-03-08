class DeviceSerializer < ApplicationSerializer
  cached true

  attributes :uri, :id, :name, :type, :properties, :physical, :pending,
             :activated, :created_at, :updated_at

  def uri
    object.decorate.uri
  end

  def type
    { uri: object.decorate.type_uri }
  end

  def properties
    object.properties.map do |property|
      property = property.decorate
      { uri: property.uri, id: property.id, value: property.value, expected: property.expected, pending: property.pending }
    end
  end

  def physical
    { uri: object.physical }
  end

  def activated
    object.activated_at ? true : false
  end
end
