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
    let(:params) {{ properties: new_device_properties }}

    it_should_behave_like "protected resource", "page.driver.put(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      it_should_behave_like "a rescued 404 resource", "page.driver.put(@uri)", "devices", "/functions"


      context "with a connected physical" do
        before { page.driver.put(@uri, params.to_json) }

        scenario "update device properties with physical response" do
          page.status_code.should == 200
          page.should have_content("\"#{Settings.properties.intensity.new_value}\"")
          page.should have_content("\"#{Settings.properties.status.new_value}\"")
          should_have_valid_json(page.body)
        end

        scenario "create a pending resource" do
          Pending.count.should == 1
          @pending = Pending.first
          @pending.pending_status.should == false
        end

        describe "history" do
          before { @history = History.first }
          before { visit "#{host}/devices/#{@resource.id}/histories" }
          scenario "store new property values" do
            should_have_history @history
            page.should have_content("\"#{Settings.properties.intensity.new_value}\"")
            page.should have_content("\"#{Settings.properties.status.new_value}\"")
          end
        end
      end


      context "with no physical device" do
        before { @resource = Factory(:device_no_physical) }
        before { @uri = "#{host}/devices/#{@resource.id}/functions?uri=#{Settings.functions.set_intensity.uri}" }
        before { page.driver.put(@uri, params.to_json) }

        scenario "update device properties" do
          page.status_code.should == 200
          page.should have_content("\"#{Settings.properties.intensity.new_value}\"")
          page.should have_content("\"#{Settings.properties.status.new_value}\"")
          should_have_valid_json(page.body)
        end
        
        scenario "do not create a pending resource" do
          Pending.count.should == 0
        end

        describe "history" do
          before { @history = History.first }
          before { visit "#{host}/devices/#{@resource.id}/histories" }
          scenario "store new properties values" do
            should_have_history @history
            page.should have_content("\"#{Settings.properties.intensity.new_value}\"")
            page.should have_content("\"#{Settings.properties.status.new_value}\"")
          end
        end
      end


      context "with not valid function uri" do
        scenario "is not found" do
          page.driver.put("#{@uri}?uri=not_existing", params.to_json)
          page.status_code.should == 404
        end
      end

    end
  end
end
