require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "FunctionsController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { Pending.destroy_all }
  before { History.destroy_all }

  # PUT /devices/{device-id}/functions?uri={function-uri}
  context ".update" do
    before { @resource = Factory(:device_complete) }
    before { @not_owned_resource = Factory(:not_owned_device) }
    before { @uri = "#{host}/devices/#{@resource.id}/functions?uri=#{Settings.functions.set_intensity.uri}" }

    it_should_behave_like "protected resource", "page.driver.put(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      let(:params) {{ 
        properties: [ 
          { uri: Settings.properties.intensity.uri, value: "10.0" },
          { uri: Settings.properties.status.uri, value: "off" }
        ]
      }}

      context "with a connected physical" do
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
          @pending.pending_status.should == false
        end

        context "with created history resource" do
          before { @history = History.first }
          before { visit "#{host}/devices/#{@resource.id}/histories" }
          scenario "represent new properties values" do
            should_have_history @history
            page.should have_content '10.0'
            page.should have_content '"off"'
          end
        end
      end


      context "with no physical device" do
        before { @resource = Factory(:device_no_physical) }
        before { @uri = "#{host}/devices/#{@resource.id}/functions?uri=#{Settings.functions.set_intensity.uri}" }
        let(:params) {{ properties: [{ uri: Settings.properties.intensity.uri, value: "10.0" }] }}
        before { page.driver.put(@uri, params.to_json) }

        scenario "update device properties" do
          page.status_code.should == 200
          page.should have_content '10.0'
          page.should have_content '"on"'
          should_have_valid_json(page.body)
        end
        
        scenario "do not create a pending resource" do
          Pending.count.should == 0
        end

        context "with created history resource" do
          before { @history = History.first }
          before { visit "#{host}/devices/#{@resource.id}/histories" }
          scenario "represent new properties values" do
            should_have_history @history
            page.should have_content '10.0'
            page.should have_content '"on"'
          end
        end
      end


      context "with not valid function uri" do
        scenario "is not found" do
          page.driver.put("#{@uri}?uri=not_existing", params.to_json)
          page.status_code.should == 404
        end
      end

      it_should_behave_like "rescued when not found", 
                            "page.driver.put(@uri)", 
                            "devices", "/functions"
    end
  end
end
