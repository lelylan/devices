require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "FunctionsController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }

  # PUT /devices/{device-id}/functions/{function-id}
  context ".update" do
    before { @resource = Factory(:device_complete) }
    before { @uri = "#{host}/devices/#{@resource.id}/functions?uri=#{Settings.functions.set_intensity.uri}" }

    context "when logged in" do
      before { basic_auth(@user) } 
      let(:params) {{ 
        properties: [ 
          { uri: Settings.properties.intensity.uri, value: "10.0" },
          { uri: Settings.properties.status.uri, value: "off" }
        ]
      }}

      context "with a connected physical" do
        before { Pending.destroy_all }
        before { page.driver.put(@uri, params.to_json) }

        scenario "shoul update device properties with physical response" do
          page.status_code.should == 200
          page.should have_content '10.0'
          page.should have_content '"off"'
          should_have_valid_json(page.body)
        end

        scenario "creates a pending resource" do
          Pending.count.should == 1
          @pending = Pending.first
          @pending.should_not be_nil
          @pending.pending_status.should == false
        end
      end

      context "with no physical device" do
        before { @resource = Factory(:device_no_physical) }
        before { @uri = "#{host}/devices/#{@resource.id}/functions?uri=#{Settings.functions.set_intensity.uri}" }
        let(:params) {{ 
          properties: [{ uri: Settings.properties.intensity.uri, value: "10.0" }]
        }}

        scenario "update device properties" do
          page.driver.put(@uri, params.to_json)
          page.status_code.should == 200
          page.should have_content '10.0'
          page.should have_content '"on"'
          should_have_valid_json(page.body)
        end
      end

      context "with not valid function uri" do
        scenario "is not found" do
          page.driver.put("#{@uri}/not_existing", params.to_json)
          page.status_code.should == 404
        end
      end
    end
  end
end
