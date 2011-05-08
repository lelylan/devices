require 'spec_helper'

describe Pending do
  before { @device = Factory(:device_complete) }

  it { should validate_presence_of :uri }
  it { should allow_value(Settings.validation.valid_uri).for(:uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:uri) }

  it { should validate_presence_of :device_uri }
  it { should allow_value(Settings.validation.valid_uri).for(:device_uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:device_uri) }
  
  it { should validate_presence_of :function_uri } 
  it { should allow_value(Settings.validation.valid_uri).for(:function_uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:function_uri) }
  
  it { should validate_presence_of :function_name }

  context "#create_pending" do
    before { @device_function = @device.device_functions.where(uri: Settings.functions.set_intensity.uri).first }
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
      before { @pending.update_pending_properties([@applied_properties.first]) }
      it "leaves open the pending resource" do
        @pending.pending_status.should == true
      end

      it "has one pending property" do
        pending_properties = @pending.pending_properties.where(pending_status: false)
        pending_properties.should have(1).items
      end
    end

    context "with one not matching property" do
      before { @property = @applied_properties.first }
      before { @property[:value] = "5.0" }
      before { @pending.update_pending_properties([@property]) }

      it "populates transitional values" do
        @pending.pending_status.should == true
        pending_property = @pending.pending_properties.where(uri: @property[:uri]).first
        pending_property.transitional_values.should include "5.0"
      end

      it "has two pending properties" do
        pending_properties = @pending.pending_properties.where(pending_status: true)
        pending_properties.should have(2).items
      end
    end
  end
end

