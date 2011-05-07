require 'spec_helper'

describe Pending do
  before { @device = Factory(:device_complete) }

  it { should allow_value(Settings.validation.valid_uri).for(:uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:uri) }

  it { should allow_value(Settings.validation.valid_uri).for(:device_uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:device_uri) }
  
  it { should allow_value(Settings.validation.valid_uri).for(:function_uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:function_uri) }
  
  context "#create_pending" do
    before { @device_function = @device.device_functions.where(function_uri: Settings.functions.set_intensity.function_uri).first }
    before { Pending.stub(:base_uri).and_return(Settings.pending.uri) }

    it "creates a pending resource" do
      lambda {
        Pending.create_pending(@device, @device_function, nil)
      }.should change{ Pending.count }.by(1)
    end
  end

  context "#create_pending_properties" do
    before { @pending = Factory(:pending) }
    before { @properties = HashWithIndifferentAccess.new(JSON.parse(Settings.unite_node_json))[:properties] }

    it "populates pending properties" do
      lambda {
        @pending.create_pending_properties(@device, @properties)
      }.should change{ @pending.pending_properties.length }.by(2)
    end
  end

  context "#update_pending_properties" do
    before { @pending = Factory(:pending_complete) }
    before { @applied_properties = HashWithIndifferentAccess.new(JSON.parse(Settings.unite_node_json))[:properties] }

    context "with all properties" do
      it "closes the pending resource" do
        @pending.update_pending_properties(@applied_properties)
        @pending.pending_status.should == false
        closed = @pending.pending_properties.where(pending_status: false)
        closed.should have(2).items
      end
    end

    context "with one property" do
      it "leaves open the pending resource" do
        @pending.update_pending_properties([@applied_properties.first])
        @pending.pending_status.should == true
        closed = @pending.pending_properties.where(pending_status: false)
        closed.should have(1).items
      end
    end
  end
end

