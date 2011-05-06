require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "PhysicalController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { @device = Factory(:device) }

  # POST /devices/{device-id}/physical
  context ".create" do
    before { @uri =  "/devices/#{@device.id.as_json}/physical" }

    context "when not logged in" do
      before { basic_auth_cleanup }
      scenario "is not authorized" do
        page.driver.post(@uri, {}.to_json)
        should_not_be_authorized
      end
    end

    context "when logged in" do
      before { basic_auth(@user) } 
      let(:params) {{ 
        physical_id: Settings.unite_node.physical_id,
        unite_node_uri: Settings.unite_node.uri 
      }}

      scenario "create connection" do
        page.driver.post(@uri, params.to_json)
        page.status_code.should == 201
        @connection = @device.reload.device_physical
        save_and_open_page
        page.should have_content @connection.physical_id
        page.should have_content @connection.unite_node_uri
      end

      context "when not valid" do
        scenario "get validation notification" do
          page.driver.post(@uri, {}.to_json)
          should_have_a_not_valid_resource
        end

        scenario "do not destroy previous physical" do
          @device.device_physicals.create!(params)
          lambda { 
            page.driver.post(@uri, {}.to_json) 
          }.should_not change{ @device.device_physicals.length }
        end
      end
    end
  end

end
