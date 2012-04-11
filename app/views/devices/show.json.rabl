object DeviceDecorator.decorate(@device)

node(:uri)     { |device| device.uri }
node(:id)      { |device| device.id }
node(:name)    { |device| device.name }
node(:type)    { |device| { uri: device.type_uri } }

node(:properties) do |device|
  device.device_properties.map do |property|
    { uri: property.uri, value: property.value }
  end
end

node(:physical) do |device|
  if device.device_physical
    { uri: device.device_physical.uri }
  else
    false
  end
end

node(:pending) { |device| { uri: device.uri + '/pending', status: device.pending } }
node(:created_at) { |device| device.created_at }
node(:updated_at) { |device| device.updated_at }
