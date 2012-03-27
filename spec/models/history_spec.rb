require 'spec_helper'

describe History do
  # presence
  it { should validate_presence_of :uri }
  it { should validate_presence_of :device_uri }

  # uri
  it { should allow_value(Settings.validation.uri.valid).for(:uri) }
  it { should_not allow_value(Settings.validation.uri.not_valid).for(:uri) }
  it { should allow_value(Settings.validation.uri.valid).for(:device_uri) }
  it { should_not allow_value(Settings.validation.uri.not_valid).for(:device_uri) }

  # general stub
  before  { stub_get(Settings.type.uri).to_return(body: fixture('type.json') ) }

  context "#create_history" do
    before { @device = Factory(:device) }
    before { @params = { device_uri: @device.uri }}
    before { @properties = json_fixture('properties.json')[:properties] }
    before { @request = nil }
    before { History.stub(:base_uri).and_return(Settings.history.uri) }

    it "creates history resource" do
      expect {
        @history = History.create_history(@params, @properties, @request)
      }.to change{ History.count }.by(1)
    end

    it "creates history properties" do
      @history = History.create_history(@params, @properties, @request)
      @history.reload.history_properties.should have(2).items
    end
  end
end
