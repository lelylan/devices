require 'spec_helper'

describe History do
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

  end
end
