module DevicesViewMethods

  def should_have_only_owned_device(device)
    device = DeviceDecorator.decorate(device)
    json = JSON.parse(page.source)
    should_contain_device(device)
    should_not_have_not_owned_devices
  end

  def should_contain_device(device)
    device = DeviceDecorator.decorate(device)
    json = JSON.parse(page.source).first
    should_have_device(device, json)
  end

  def should_have_device(device, json = nil)
    device = DeviceDecorator.decorate(device)
    should_have_valid_json
    json = JSON.parse(page.source) unless json 
    json = Hashie::Mash.new json
    json.uri.should == device.uri
    json.id.should == device.id.as_json
    json.name.should == device.name
    json.type.uri.should == device.type_uri
    json.properties.each_with_index do |property, index|
      property.uri.should == device.device_properties[index].uri
      property.value.should == device.device_properties[index].value
    end
    json.physical.uri.should == device.device_physical.uri if device.device_physical
    json.physical.should be_false if !device.device_physical
    json.pending.uri.should == device.uri + '/pending'
    json.pending.status.should == device.pending
  end

  def should_not_have_not_owned_devices
    should_have_valid_json
    json = JSON.parse(page.source)
    json.should have(1).item
    Device.all.should have(2).items
  end

end

RSpec.configuration.include DevicesViewMethods
