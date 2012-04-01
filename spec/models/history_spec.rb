require 'spec_helper'

describe History do
  # presence
  it { should validate_presence_of :device_uri }

  # general stub
  before  { stub_get(Settings.type.uri).to_return(body: fixture('type.json') ) }

  context "#create_history" do
    before { @params = { device_uri: Settings.device.uri }}
    before { @properties = json_fixture('properties.json')[:properties] }

    it "should create history resource" do
      expect {
        @history = History.create_history(@params, @properties)
      }.to change{ History.count }.by(1)
    end

    it "should create history properties" do
      @history = History.create_history(@params, @properties)
      @history.reload.history_properties.should have(2).items
    end
  end
end
