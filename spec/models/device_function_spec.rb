require 'spec_helper'

describe DeviceFunction do
  before { @device = Factory(:device_complete) }
  before { @device_function = @device.device_functions.where(uri: Settings.functions.set_intensity.uri).first }

  describe "#function_representation" do
    before { @function = Lelylan::Type.function(@device_function.uri) }
    it "gets json representation" do
      @function[:name].should == Settings.functions.set_intensity.name
    end

    describe "#populate_properties" do
      before { @params = { properties: [{ uri: Settings.properties.intensity.uri , value: "10.0" }]} }
      before { @properties = @device_function.populate_properties(@function[:properties], @params[:properties]) }
      subject { @properties }
      it { should have(2).properties }

      describe "#to_parameters" do
        before { @properties = @device_function.to_parameters(@params[:properties]) }
        subject { @properties }
        it { should have(2).properties }
      end
    end
  end
end
