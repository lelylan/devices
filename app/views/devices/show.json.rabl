object @device

node(:uri)  { |device| device.uri }
node(:id)   { |device| device.id }
node(:name) { |device| device.name }
node(:type) { |device| { uri: device.type_uri } }

node(:properties) do |device|
  device.device_properties.map do |property|
    { uri: property.uri, value: property.value }
  end
end

node(:physical) do |device|
  { uri: device.device_physicals.first.uri }
end

node(:created_at) { |device| device.created_at }
node(:updated_at) { |device| device.updated_at }
