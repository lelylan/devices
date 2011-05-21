require 'spec_helper'

describe Device do
  before { @device = Factory(:device) }
  before { Pending.destroy_all }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:type_uri) }

  it { should allow_value(Settings.validation.valid_uri).for(:uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:uri) }
  it { should allow_value(Settings.validation.valid_uri).for(:created_from) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:created_from) }
  it { should allow_value(Settings.validation.valid_uri).for(:type_uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:type_uri) }

  it { should_not allow_mass_assignment_of(:uri) }
  it { should_not allow_mass_assignment_of(:created_from) }
  it { should_not allow_mass_assignment_of(:type_name) }

  # Type population of properties and functions
  context "#sync_type" do
    before  { @device.sync_type(Settings.type.uri) }
    subject { @device.reload }

    its(:device_properties) { should have(2).properties }
    its(:device_functions) { should have(3).functions }
    its(:type_name) { should == Settings.type.name }

    context "#type_representation" do
      before { @type = @device.type_representation(Settings.type.uri) }
      it "gets json representation" do
        @type[:name].should == Settings.type.name
      end
      
      context "#sync_properties" do
        before  { @device.sync_properties(@type[:properties]) }
        subject { @device.reload.device_properties }
        it { should have(2).properties }
      end

      context "#sync_functions" do
        before  { @device.sync_functions(@type[:functions]) }
        subject { @device.reload.device_functions }
        it { should have(3).functions }
      end
    end
  end

  # Pending values property update on device
  describe "#update pending properties" do
    before { @device = Factory(:device_complete) }

    context "with open pendings" do
      before { @closed_pending = Factory(:closed_pending) }
      before { @open_pending = Factory(:pending_complete) }
      before { @device.update_pending_properties }
      it "should have all properties pending" do
        @device.reload.device_properties.each do |device_property|
          device_property.pending.should == true
        end
      end
    end

    context "with half pendings" do
      before { @closed_pending = Factory(:closed_pending) }
      before { @open_pending = Factory(:pending_complete) }
      before { @half_pending = Factory(:half_pending) } 
      before { @device.update_pending_properties }
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

    context "with closed pendings" do
      before { @closed_pending = Factory(:closed_pending) }
      before { @device.update_pending_properties }
      it "should have all properties closed" do
        @device.reload.device_properties.each do |device_property|
          device_property.pending.should == false
        end
      end
    end
  end
end
