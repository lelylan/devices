module ConsumptionViewMethods

  def should_have_only_owned_consumption(consumption)
    consumption = ConsumptionDecorator.decorate(consumption)
    json = JSON.parse(page.source)
    should_contain_consumption(consumption)
    should_not_have_not_owned_consumptions
  end

  def should_contain_consumption(consumption)
    consumption = ConsumptionDecorator.decorate(consumption)
    json = JSON.parse(page.source).first
    should_have_consumption(consumption, json)
  end

  def should_have_consumption(consumption, json = nil)
    consumption = ConsumptionDecorator.decorate(consumption)
    should_have_valid_json
    json = JSON.parse(page.source) unless json 
    json = Hashie::Mash.new json
    json.uri.should == consumption.uri
    json.id.should == consumption.id.as_json
    json.device.uri.should == consumption.device_uri
    json.type.should == consumption.type
    json.value.should == consumption.value
    json.unit == consumption.unit
    json.occur_at == consumption.occur_at
    check_durational(consumption, json)
  end

  def check_durational(consumption, json)
    if consumption.durational?
      json.occur_at == consumption.occur_at
      json.duration == consumption.duration
      page.source.should have_content 'end_at'
      page.source.should have_content 'duration'
    else
      page.source.should_not have_content 'end_at'
      page.source.should_not have_content 'duration'
    end
  end

  def should_not_have_not_owned_consumptions
    should_have_valid_json
    json = JSON.parse(page.source)
    json.should have(1).item
    Consumption.all.should have(2).items
  end

end

RSpec.configuration.include ConsumptionViewMethods
