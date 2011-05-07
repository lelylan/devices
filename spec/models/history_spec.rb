require 'spec_helper'

describe History do
  #it { should validate_presence_of :uri }
  it { should allow_value(Settings.validation.valid_uri).for(:uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:uri) }

  #it { should validate_presence_of :device_uri }
  it { should allow_value(Settings.validation.valid_uri).for(:device_uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:device_uri) }
  
  context "#create_history" do
    context "with pending" do
      before { @device = Factory(:device_complete) }
      before { @pending = Factory(:pending_complete) }
      before { History.stub(:base_uri).and_return(Settings.history.uri) }

      it "creates history" do
        lambda {
          History.create_history(@device.uri, @pending.pending_properties, nil)
        }.should change{ History.count }.by(1)
      end
    end
  end

end
