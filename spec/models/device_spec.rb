require 'spec_helper'

describe Device do
  before { @device = Factory(:device) }

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

  # Function to properties
  context "#function_representation" do
    before { @function = @device.function_representation(Settings.functions.intensity.uri) }
    it "gets json representation" do
      @function[:name].should == Settings.functions.intensity.name
    end

    context "#populate_properties" do
      before { @params = { properties: [{ uri: Settings.property.uri , value: "4.0" }]} }
      before { @properties = @device.populate_properties(@function[:properties], @params[:properties]) }
      subject { @properties }
      it { should have(2).properties }

      context "#function_to_parameters" do
        before { @properties = @device.function_to_parameters(Settings.functions.intensity.uri, @params[:properties]) }
        subject { @properties }
        it { should have(2).properties }
      end
    end
  end

end
