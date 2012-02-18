require 'spec_helper'

describe Device do
  before { Pending.destroy_all }

  # presence
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:type_uri) }

  # uri
  it { should allow_value(Settings.validation.uri.valid).for(:uri) }
  it { should_not allow_value(Settings.validation.uri.not_valid).for(:uri) }
  it { should allow_value(Settings.validation.uri.valid).for(:created_from) }
  it { should_not allow_value(Settings.validation.uri.not_valid).for(:created_from) }
  it { should allow_value(Settings.validation.uri.valid).for(:type_uri) }
  it { should_not allow_value(Settings.validation.uri.not_valid).for(:type_uri) }

  # mass assignment
  it { should_not allow_mass_assignment_of(:uri) }
  it { should_not allow_mass_assignment_of(:created_from) }



  describe "#create_physical_connection" do
    context "when valid" do
      before { @physical = {uri: Settings.physical.uri} }
      subject { Factory(:device_no_physical, physical: @physical).device_physicals }
      it { should have(1).item }
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
    before { @device = Factory(:device_no_connections) }

    before  { stub_get(Settings.type.uri).to_return(body: fixture('type.json') ) }
    before  { @device.synchronize_type }
    subject { @device.reload }

    its(:device_properties) { should have(2).properties }

    context "Lelylan::Type.type" do
      before { @type = Lelylan::Type.type(Settings.type.uri) }
      it "gets json representation" do
        @type[:name].should == "Dimmer"
      end

      context "#synchronize_properties" do
        before  { @device.synchronize_properties(@type[:properties]) }
        subject { @device.reload.device_properties }
        it { should have(2).properties }
      end
    end
  end



  context "synchronize_device"



  # Pending values property update on device
  describe "#update_open_pendings" do
    before { @device = Factory(:device) }


    context "with open pendings" do
      before { @pending_closed = Factory(:pending_closed) }
      before { @pending_open   = Factory(:pending) }
      before { @device.update_open_pendings }

      it "should have all properties pending" do
        @device.reload.device_properties.each do |device_property|
          device_property.pending.should == true
        end
      end
    end


    context "with a pending property" do
      before { @pending_closed    = Factory(:pending_closed) }
      before { @pending_intenisty = Factory(:pending_intensity) } 
      before { @device.update_open_pendings }

      describe "open property connection" do
        subject { @device.reload.device_properties.where(pending:true).first }
        it { should_not be_nil }
        its(:uri) { should == Settings.properties.intensity.uri }
      end

      describe "closed property connection" do
        subject { @device.reload.device_properties.where(pending:false).first }
        it { should_not be_nil }
        its(:uri) { should == Settings.properties.status.uri }
      end
    end


    context "with more than one open pending per property" do
      before { @closed_pending = Factory(:pending_closed) }
      before { @open_pending = Factory(:pending) }
      before { @half_pending = Factory(:pending_intensity) } 
      before { @device.update_open_pendings }

      it "should have all properties open" do
        @device.reload.device_properties.each do |device_property|
          device_property.pending.should == true
        end
      end
    end


    context "with closed pending" do
      before { @closed_pending = Factory(:pending_closed) }
      before { @device.update_open_pendings }

      it "should have all properties closed" do
        @device.reload.device_properties.each do |device_property|
          device_property.pending.should == false
        end
      end
    end
  end
end
