require 'spec_helper'

describe DeviceFunction do
  before { @device = Factory(:device_complete) }
  before { @device_function = @device.device_functions.where(uri: Settings.functions.set_intensity.uri).first }

  context "#function_representation" do
    before { @function = @device_function.function_representation }
    it "gets json representation" do
      @function[:name].should == Settings.functions.set_intensity.name
    end

    context "#populate_properties" do
      before { @params = { properties: [{ uri: Settings.properties.intensity.uri , value: "10.0" }]} }
      before { @properties = @device_function.populate_properties(@function[:properties], @params[:properties]) }
      subject { @properties }
      it { should have(2).properties }

      context "#to_parameters" do
        before { @properties = @device_function.to_parameters(@params[:properties]) }
        subject { @properties }
        it { should have(2).properties }
      end
    end
  end
end
