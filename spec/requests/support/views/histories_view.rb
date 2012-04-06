module HistoriesViewMethods

  def should_have_only_owned_history(history)
    history = HistoryDecorator.decorate(history)
    json = JSON.parse(page.source)
    should_contain_history(history)
    should_not_have_not_owned_histories
  end

  def should_contain_history(history)
    history = HistoryDecorator.decorate(history)
    json = JSON.parse(page.source).first
    should_have_history(history, json)
  end

  def should_have_history(history, json = nil)
    history = HistoryDecorator.decorate(history)
    should_have_valid_json
    json = JSON.parse(page.source) unless json 
    json = Hashie::Mash.new json
    json.uri.should == history.uri
    json.id.should == history.id.as_json
    json.device.uri.should == history.device_uri
    json.properties.each_with_index do |property, index|
      property.uri.should == history.history_properties[index].uri
      property.value.should == history.history_properties[index].value
    end
  end

  def should_not_have_not_owned_histories
    should_have_valid_json
    json = JSON.parse(page.source)
    json.should have(1).item
    History.all.should have(2).items
  end

end

RSpec.configuration.include HistoriesViewMethods
