require 'spec_helper'

describe Device do
  before { @device = Factory(:device) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:type_uri) }
  it { should validate_presence_of(:type_name) }

  it { should allow_value(Settings.validation.valid_uri).for(:uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:uri) }
  it { should allow_value(Settings.validation.valid_uri).for(:created_from) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:created_from) }
  it { should allow_value(Settings.validation.valid_uri).for(:type_uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:type_uri) }

  it { should_not allow_mass_assignment_of(:uri) }
  it { should_not allow_mass_assignment_of(:created_from) }
  it { should_not allow_mass_assignment_of(:type_uri) }
  it { should_not allow_mass_assignment_of(:type_name) }

  context ".sync_type" do
    before  { @device.sync_type(Settings.type.uri) }
    subject { @device.reload }
    its(:device_properties) { should have(2).properties }
    its(:device_functions) { should have(3).functions }
  end

  context ".type_representation" do
    before { @type = @device.type_representation(Settings.type.uri) }
    it "gets json representation" do
      @type[:name].should == Settings.type.name
    end
    
    context ".sync_properties" do
      before  { @device.sync_properties(@type[:properties]) }
      subject { @device.reload.device_properties }
      it { should have(2).properties }
    end

    context ".sync_functions" do
      before  { @device.sync_functions(@type[:functions]) }
      subject { @device.reload.device_functions }
      it { should have(3).functions }
    end
  end
end
