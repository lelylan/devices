module HelpersViewMethods
  def has_consumption(consumption, json = nil)
    json.device.uri.should == consumption.device_uri
    json.uri.should   == consumption.uri
    json.id.should    == consumption.id.as_json
    json.type.should  == consumption.type
    json.value.should == consumption.value
    json.unit.should  == consumption.unit
    json.occur_at.should_not be_nil

    if consumption.durational?
      json.end_at.should_not be_nil
      json.duration.should == consumption.duration
    end

    if consumption.instantaneous?
      page.should_not have_content 'end_at'
      page.should_not have_content 'duration'
    end
  end
end

RSpec.configuration.include HelpersViewMethods
