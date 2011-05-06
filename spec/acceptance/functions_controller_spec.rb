require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "FunctionsController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }

  # PUT /devices/{device-id}/functions/{function-id}
  context ".update" do
    before { @resource = Factory(:device_complete) }
    before { @uri = "#{host}/devices/#{@resource.id}/functions?function_uri=#{Settings.functions.set_intensity.function_uri}" }

    context "when logged in" do
      before { basic_auth(@user) } 
      let(:params) {{ 
        properties: [ { uri: Settings.properties.intensity.uri, value: "10.0" } ]
      }}

      context "when valid function uri" do
        scenario "create resource" do
          page.driver.put(@uri, params.to_json)
          page.status_code.should == 200
          save_and_open_page
        end
      end

      context "when not valid function uri" do
        scenario "is not found" do
          page.driver.put("#{@uri}/not_exising", params.to_json)
          page.status_code.should == 404
        end
      end
    end
  end
end
