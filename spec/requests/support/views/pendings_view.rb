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

  #def should_not_have_not_owned_pendings
    #should_have_valid_json
    #json = JSON.parse(page.source)
    #json.should have(1).item
    #Device.all.should have(2).items
  #end

end

RSpec.configuration.include PendingsViewMethods
