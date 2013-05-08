module HelpersViewMethods
  def has_device(device, json = nil)
    json.uri.should       == device.uri
    json.id.should        == device.id.to_s
    json.name.should      == device.name
    json.type.uri.should  == device.type_uri
    json.type.id.should   == device.type_id.to_s
    json.pending.should   == device.pending
    json.activated.should == (device.activated_at ? true : false)
    json.secret.should    == nil

    json.owner.uri.should == device.owner_uri
    json.owner.id.should  == device.resource_owner_id.to_s
    json.maker.uri.should == device.maker_uri
    json.maker.id.should  == device.maker_id.to_s
    json.updated_from.should == device.updated_from

    json.properties.each_with_index do |property, i|
      device_property = DevicePropertyDecorator.decorate(device.properties[i])
      property.uri.should   == device_property.uri
      property.id.should    == device_property.id.to_s
      property.value.should == device_property.value
      property.expected.should == device_property.expected
      property.pending.should == device_property.pending
      property.accepted.should == device_property.accepted
    end

    physical = HashWithIndifferentAccess.new device.physical if json.physical
    json.physical.uri.should == physical[:uri]  if json.physical
    json.physical == nil if not json.physical
  end
end

RSpec.configuration.include HelpersViewMethods
