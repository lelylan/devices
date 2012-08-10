module HelpersViewMethods
  def has_device(device, json = nil)
    json.uri.should  == device.uri
    json.id.should   == device.id.to_s
    json.name.should == device.name
    json.type.uri.should == device.type_uri
    json.pending.should  == device.pending

    json.properties.each_with_index do |property, i|
      property.uri.should   == DevicePropertyDecorator.decorate(device.properties[i]).uri
      property.value.should == device.properties[i].value
    end

    json.physical.should eq (device.physical ? {'uri' => device.physical.uri} : {})
  end
end

RSpec.configuration.include HelpersViewMethods
