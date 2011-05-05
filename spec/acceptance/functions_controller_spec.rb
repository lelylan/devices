require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "FunctionsController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }

  # PUT /devices/{device-id}/functions/{function-id}
  context ".update" do
    before { @device = Factory(:device) }
    before { @uri = "#{host}/devices/#{@device.id}/functions/#{Settings.functions.intensity.id}" }

    context "when logged in" do
      before { basic_auth(@user) } 
      let(:params) {[{ uri: Settings.functions.intensity.uri, value: "4.0" }]}

      # Working function call
      context "when valid function uri" do
        before { create_device_function(@uri) }
        scenario "create resource" do
          page.driver.put(@uri, params.to_json)
          page.status_code.should == 200
        end
      end

      # Missing function call
      context "when not valid function uri" do
        before { create_device_function("#{@uri}no") }
        scenario "is not found" do
          page.driver.put(@uri, params.to_json)
          page.status_code.should == 404
        end
      end
    end

  end
end


def create_device_function(uri)
  @device.device_functions.create!(
    uri: uri,
    function_uri: Settings.functions.intensity.uri,
    name: Settings.functions.intensity.name )
end

