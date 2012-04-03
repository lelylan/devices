require 'spec_helper'

describe Device do
  # presence
  it { should validate_presence_of(:created_from) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:type_uri) }

  # mass assignment
  it { should_not allow_mass_assignment_of(:created_from) }

  # general stub
  before  { stub_get(Settings.type.uri).to_return(body: fixture('type.json') ) }

  describe "#create_physical_connection" do
    context "when valid" do
      before { @physical = {uri: Settings.physical.uri} }
      subject { Factory(:device_no_physical, physical: @physical).device_physical }
      it { should_not be_nil }
    end

    context "when not valid" do
      context "with no uri field" do
        before { @physical = {} }
        it "should get a not valid notification" do
          lambda{ 
            Factory(:device_no_physical, physical: @physical)
          }.should raise_error(Mongoid::Errors::Validations)
        end
      end

      context "when sent as Array" do
        before { @physical = [] }
        it "should get a not valid notification" do
          lambda{ 
            Factory(:device_no_physical, physical: @physical) 
          }.should raise_error(Mongoid::Errors::InvalidType)
        end
      end
    end
  end



  context "#synchronize_type" do
    before  { @device = Factory(:device_no_connections) }
    subject { @device }

    its(:device_properties) { should have(2).properties }

    context "Lelylan::Type.type" do
      before { @type = Lelylan::Type.type(Settings.type.uri) }

      it "should return a json representation" do
        @type[:name].should == "Dimmer"
      end

      context "#synchronize_properties" do
        before  { @device = Factory.build(:device_no_connections) }
        before  { @device.synchronize_properties(@type[:properties]); }
        subject { @device.device_properties }
        it { should have(2).properties }
      end
    end
  end



  context "synchronize_device" do
    before { @properties = json_fixture('properties.json')[:properties] }

    context "with physical connection" do
      before  { stub_request(:put, Settings.physical.uri).with(body: {properties: @properties}) }
      before  { @device = Factory(:device) }
      before  { @device.synchronize_device(@properties) }

      it "should change device property status" do
        @device.reload.device_properties[0][:value].should == "on"
      end

      it "should change device property intensity" do
        @device.reload.device_properties[1][:value].should == "100.0"
      end

      it "should update the physical device" do
        a_put(Settings.physical.uri, false).with(body: {properties: @properties}).should have_been_made.once
      end
    end


    context "without physical connection" do
      before  { @device = Factory(:device_no_physical) }
      before  { @device.synchronize_device(@properties) }

      it "should change device property status" do
        @device.reload.device_properties[0][:value].should == "on"
      end

      it "should change device property intensity" do
        @device.reload.device_properties[1][:value].should == "100.0"
      end
    end
  end

end
