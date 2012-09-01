module HelpersViewMethods
  def has_device(device, json = nil)
    json.uri.should  == device.uri
    json.id.should   == device.id.to_s
    json.name.should == device.name
    json.type.uri.should == device.type_uri
    json.pending.should  == device.pending

    json.properties.each_with_index do |property, i|
      device_property = DevicePropertyDecorator.decorate(device.properties[i])
      property.uri.should      == device_property.uri
      property.id.should       == device_property.id.to_s
      property.value.should    == device_property.value
      property.physical.should == device_property.physical
    end

    json.physical.should eq (device.physical ? {'uri' => device.physical.uri} : {})
  end
end

RSpec.configuration.include HelpersViewMethods
