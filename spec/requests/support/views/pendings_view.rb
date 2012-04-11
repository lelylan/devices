module PendingsViewMethods
  def should_have_pending(pending, json = nil)
    pending = DeviceDecorator.decorate(pending)
    should_have_valid_json
    json = JSON.parse(page.source) unless json 
    json = Hashie::Mash.new json
    json.uri.should == pending.uri
    json.properties.each_with_index do |property, index|
      property.uri.should == pending.device_properties[index].uri
      property.value.should == pending.device_properties[index].pending
    end
  end
end

RSpec.configuration.include PendingsViewMethods
