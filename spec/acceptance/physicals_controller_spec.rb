require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "PhysicalController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { @resource = Factory(:device_no_physical) }
  before { @not_owned_resource = Factory(:not_owned_device) }

  let(:params) {{ physical_id: Settings.unite_node.physical_id,
                  unite_node_uri: Settings.unite_node.uri }}

  # POST /devices/{device-id}/physical
  context ".create" do
    before { @uri =  "/devices/#{@resource.id.as_json}/physical" }

    it_should_behave_like "protected resource", "page.driver.post(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 

      scenario "create connection" do
        page.driver.post(@uri, params.to_json)
        page.status_code.should == 201
        @connection = @resource.reload.device_physical
        page.should have_content @connection.physical_id
        page.should have_content @connection.unite_node_uri
        should_have_valid_json(page.body)
      end

      context "when not valid" do
        scenario "get not valid notification" do
          page.driver.post(@uri, {}.to_json)
          should_have_a_not_valid_resource
        end

        scenario "do not destroy previous physical" do
          @resource.device_physicals.create!(params)
          lambda { 
            page.driver.post(@uri, {}.to_json) 
          }.should_not change{ @resource.device_physicals.length }
        end
      end

      it_should_behave_like "rescued when not found", 
        "page.driver.post(@uri)", "devices", "/physical"
    end
  end


  # DELETE /devices/{device-id}/physical
  context ".destroy" do
    before { @uri =  "/devices/#{@resource.id.as_json}/physical" }

    it_should_behave_like "protected resource", "page.driver.delete(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      scenario "delete connection" do
        @resource.device_physicals.create!(params)
        @resource.device_physicals.should have(1).item
        page.driver.delete(@uri)
        page.status_code.should == 204
        @resource.reload.device_physicals.should have(0).items
      end

      it_should_behave_like "rescued when not found", 
        "page.driver.delete(@uri)", "devices", "/physical"
    end
  end  
end
