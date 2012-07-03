object DeviceDecorator.decorate(@device)

node(:uri) { |device| device.uri }
node(:status) { |device| device.pending }

node(:properties) do |device|
  device.device_properties.map do |property|
    { uri: property.uri, value: property.pending }
  end
end
