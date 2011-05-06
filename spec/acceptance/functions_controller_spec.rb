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
      let(:params) {{ 
        properties: [
          { uri: Settings.property.uri, value: "4.0" }
        ]
      }}

      # Working function call
      context "when valid function uri" do
        before { create_device_function(@uri) }
        before { create_device_physical }
        scenario "create resource" do
          page.driver.put(@uri, params.to_json)
          page.status_code.should == 200
        end
      end

      # Not valid function URI
      context "when not valid function uri" do
        before { create_device_function("#{@uri}_wrong") }
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

def create_device_physical()
  @device.device_physicals.create!(
    physical_id: Settings.unite_node.physical_id,
    unite_node_uri: Settings.unite_node.uri )
end
