require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "PhysicalsController" do
  before { Device.destroy_all }
  before { host! "http://" + host }

  before { stub_get(Settings.type.uri).to_return(body: fixture('type.json') ) }
  before { stub_get(Settings.type.another.uri).to_return(body: fixture('type.json') ) }

  before { @resource = Factory(:device) }
  before { @resource_not_owned = Factory(:device_not_owned) }
  before { @uri = "/devices/#{@resource.id.as_json}/physical" }
  before { @params = { uri: Settings.physical.uri } }


  ## ----------------------------
  ## PUT /devices/:id/physical
  ## ----------------------------
  context ".update" do

    it_should_behave_like "not authorized resource", "page.driver.put(@uri)"

    context "when logged in" do
      before { basic_auth }

      context "with exisiting physical connection" do
        it "should replace it" do
          page.driver.put @uri, @params.to_json
          @resource.reload
          page.status_code.should == 200
          should_have_device @resource
          page.should have_content @params[:uri]
        end
      end

      context "whit not existing physical connection" do
        before { @resource = Factory(:device_no_physical) }
        before { @uri =  "/devices/#{@resource.id.as_json}/physical" }
        before { @params = { uri: Settings.physical.another.uri } }

        it "should create it" do
          page.driver.put @uri, @params.to_json
          @resource.reload
          page.status_code.should == 200
          should_have_device @resource
          page.should have_content @params[:uri]
        end
      end

      context "with no valid params" do
        it "should not update the resource" do
          page.driver.put @uri, {}.to_json
          page.status_code.should == 422
          should_have_a_not_valid_resource error: 'is not a valid URL', method: 'PUT'
        end
      end

      it_should_behave_like "a rescued 404 resource", "page.driver.delete(@uri)", "devices"
      it_validates "not valid JSON", "page.driver.put(@uri, @params.to_json)", "PUT"
    end
  end


  #------------------------------
  # DELETE /devices/:id/physical
  #------------------------------
  context ".destroy" do

    it_should_behave_like "not authorized resource", "page.driver.delete(@uri)"

    context "when logged in" do
      before { basic_auth } 

      scenario "delete resource" do
        page.driver.delete(@uri, @params.to_json) 
        @resource.reload
        page.status_code.should == 200
        should_have_device @resource
        page.should_not have_content @params[:uri]
      end

      it_should_behave_like "a rescued 404 resource", "page.driver.delete(@uri)", "devices"
    end
  end

end
