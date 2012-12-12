module HelpersViewMethods

  def has_history(history, json = nil)
    json.device.uri.should == history.device_uri
    json.uri.should == history.uri
    json.id.should  == history.id.as_json

    json.properties.each_with_index do |property, i|
      property.uri.should == HistoryPropertyDecorator.decorate(history.properties[i]).uri
      property.value.should == history.properties[i].value
      property.expected_value.should == history.properties[i].expected_value
      property.pending.should == history.properties[i].pending
    end
  end
end

RSpec.configuration.include HelpersViewMethods
