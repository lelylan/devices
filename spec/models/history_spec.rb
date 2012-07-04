require 'spec_helper'

describe History do
<<<<<<< HEAD
  # presence
  it { should validate_presence_of :device_uri }
  it { should validate_presence_of :created_from }

  # general stub
  before  { stub_get(Settings.type.uri).to_return(body: fixture('type.json') ) }

  context "#create_history" do
    before { @params = { device_uri: Settings.device.uri, created_from: Settings.user.uri }}
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
=======
  it { should validate_presence_of :uri }
  it { should allow_value(Settings.validation.valid_uri).for(:uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:uri) }

  it { should validate_presence_of :device_uri }
  it { should allow_value(Settings.validation.valid_uri).for(:device_uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:device_uri) }
  
  context "#create_history" do

    context "when closes pending" do
      before { @device = Factory(:device_complete) }
      before { @pending = Factory(:pending_complete) }
      before { @properties = @pending.pending_properties }
      before { History.stub(:base_uri).and_return(Settings.history.uri) }

      it "creates history" do
        lambda {
          @history = History.create_history(@device.uri, @properties, nil)
        }.should change{ History.count }.by(1)
      end

      it "creates history properties" do
        @history = History.create_history(@device.uri, @properties, nil)
        @history.history_properties.should have(2).items
      end
    end

    context "when physical changes" do
      before { @device = Factory(:device_complete) }
      before { @pending = Factory(:pending_complete) }
      before { @properties =  new_device_properties }
      before { History.stub(:base_uri).and_return(Settings.history.uri) }

      it "creates history" do
        lambda {
          @history = History.create_history(@device.uri, @properties, nil)
        }.should change{ History.count }.by(1)
      end

      it "creates history properties" do
        @history = History.create_history(@device.uri, @properties, nil)
        @history.history_properties.should have(2).items
      end
    end

>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
  end
end
