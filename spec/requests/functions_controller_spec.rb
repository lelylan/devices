require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "FunctionsController" do
  before { host! "http://" + host }
  before { Device.destroy_all }
 
  # General stub
  before { stub_get(Settings.type.uri).to_return(body: fixture('type.json') ) }


  # -------------------------------------
  # PUT /devices/:id/functions?uri=:uri
  # -------------------------------------
  context ".update" do
    before { @resource = Factory(:device) }
    before { @resource_not_owned = Factory(:device_not_owned) }
    before { @uri = "/devices/#{@resource.id.as_json}/functions?uri=#{Settings.functions.set_intensity.uri}" }

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

        # Nothing is sent into the request
        it "uses function properties" do
          page.driver.put @uri, nil
          @resource.reload
          @resource.device_properties[0][:value].should == "on"
          @resource.device_properties[1][:value].should == ""
          @resource.device_properties[1][:value].should_not == "100.0"
          page.status_code.should == 200
          should_have_valid_json
        end

        # Intensity is sent through the request
        it "override not setted function property" do
          @params[:properties].delete_at(0)
          page.driver.put @uri, @params.to_json
          @resource.reload
          @resource.device_properties[0][:value].should == "on"
          @resource.device_properties[1][:value].should == "100.0"
          page.status_code.should == 200
          should_have_valid_json
        end

        # Intensity and status values are sent through the request
        it "overrides all functions properties" do
          page.driver.put @uri, @params.to_json
          @resource.reload
          @resource.device_properties[0][:value].should == "on"
          @resource.device_properties[1][:value].should == "100.0"
          page.status_code.should == 200
          should_have_valid_json
        end

        # Status is sent through the request with a different value 
        # from the one preset in the function
        it "overrides one function property" do
          @params[:properties][0][:value] = 'off'
          page.driver.put @uri, @params.to_json
          @resource.reload
          @resource.device_properties[0][:value].should == "off"
          @resource.device_properties[1][:value].should == "100.0"
          page.status_code.should == 200
          should_have_valid_json
        end
      end


      # -------------------------
      # Physical device related
      # -------------------------
      context "with a physical device" do
        it "updates physical device" do
          page.driver.put @uri, @params.to_json
          page.status_code.should == 200
          a_put(Settings.physical.uri).with(body: {properties: @properties}).should have_been_made.once
        end
      end

      context "with no physical device" do
        before { @resource = Factory(:device_no_physical) }
        before { @uri = "/devices/#{@resource.id.as_json}/functions?uri=#{Settings.functions.set_intensity.uri}" }

        it "does not update physical device" do
          page.driver.put @uri, @params.to_json
          page.status_code.should == 200
          a_put(Settings.physical.uri).with(body: {properties: @properties}).should_not have_been_made
        end
      end


      # ---------
      # History 
      # ---------
      it "creates history resource" do
      end


      # --------------------------------
      # Resource or function not found
      # --------------------------------
      context "when function uri is not found" do
        before { @uri = "/devices/#{@resource.id.as_json}/functions?uri=#{Settings.functions.another.uri}" }

        it "returns a not found message" do
          page.driver.put @uri, @params.to_json
          page.status_code.should == 404
          should_have_not_found_resource uri: Settings.functions.another.uri, code: 'notifications.function.not_found'
        end
      end

      it_should_behave_like "a rescued 404 resource", "page.driver.put(@uri)", "devices"
    end
  end
end
