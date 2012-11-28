class DeviceSerializer < ActiveModel::Serializer
  attributes :uri, :id, :name, :type, :properties, :physical, :pending,
             :activated, :created_at, :updated_at

  def uri
    DeviceDecorator.decorate(device).uri
  end

  def type
    { uri: DeviceDecorator.decorate(device).type_uri }
  end

  def properties
    device.properties.map do |property|
      property = DevicePropertyDecorator.decorate property
      { uri: property.uri, id: property.id, value: property.value, physical: property.physical }
    end
  end

  def physical
    { uri: device.physical }
  end

  def activated
    device.activated_at ? true : false
  end
end
