require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "PropertiesController" do
  before { Device.destroy_all }
  before { stub_get(Settings.type.uri).to_return(body: fixture('type.json') ) }


  # -------------------------------------
  # PUT /devices/:id/properties
  # -------------------------------------
  context ".update" do
    before { @resource = Factory(:device) }
    before { @resource_not_owned = Factory(:device_not_owned) }
    before { @uri = "/devices/#{@resource.id.as_json}/properties" }

    before { @properties = json_fixture('properties.json')[:properties] }
    before { @params = { properties: @properties } }

    it_should_behave_like "not authorized resource", "page.driver.put(@uri)"


    context "when logged in" do
      before { basic_auth } 
      before { stub_request(:put, Settings.physical.uri) }


      # ------------------
      # Property updates
      # ------------------
      context "when updating device properties" do

        it "should change properties" do
          page.driver.put @uri, @params.to_json
          @resource.reload
          @resource.device_properties[0][:value].should == "on"
          @resource.device_properties[1][:value].should == "100.0"
          page.status_code.should == 202
          should_have_valid_json
        end

        context "when nothing is sent" do
          it "should not change" do
            page.driver.put @uri, nil
            @resource.reload
            @resource.device_properties[0][:value].should == "off"
            @resource.device_properties[1][:value].should == ""
            page.status_code.should == 202
            should_have_valid_json
          end
        end

        it_validates "not valid JSON", "page.driver.put(@uri, @params.to_json)", "PUT"
      end


      # -------------------------
      # Physical device related
      # -------------------------
      context "with a physical device" do
        it "should update physical device" do
          page.driver.put @uri, @params.to_json
          page.status_code.should == 202
          a_put(Settings.physical.uri).with(body: {properties: @properties}).should have_been_made.once
        end
      end

      context "with no physical device" do
        before { @resource = Factory(:device_no_physical) }
        before { @uri = "/devices/#{@resource.id.as_json}/properties" }

        it "should not update physical device" do
          page.driver.put @uri, @params.to_json
          page.status_code.should == 200
          a_put(Settings.physical.uri).with(body: {properties: @properties}).should_not have_been_made
        end
      end


      # ---------------------
      # History and Pending
      # ---------------------
      it "should create history resource" do
        expect{ page.driver.put @uri, @params.to_json }.to change{ History.count }.by(1)
      end

      it "should start pending" do
        page.driver.put @uri, @params.to_json
        @resource.pending.should be_false
        @resource.reload.pending.should be_true
      end

      it_should_behave_like "a rescued 404 resource", "page.driver.put(@uri)", "devices"
    end
  end
end
