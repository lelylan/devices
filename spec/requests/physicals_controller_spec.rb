require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "PhysicalsController" do
  before { Device.destroy_all }
  before { host! "http://" + host }

  before { stub_get(Settings.type.uri).to_return(body: fixture('type.json') ) }
  before { stub_get(Settings.type.another.uri).to_return(body: fixture('type.json') ) }



  ## ----------------------------
  ## PUT /devices/:id/physical
  ## ----------------------------
  context ".update" do
    before { @resource = Factory(:device_no_physical) }
    before { @uri =  "/devices/#{@resource.id.as_json}/physical" }

    it_should_behave_like "not authorized resource", "page.driver.put(@uri)"

    context "when logged in" do
      before { basic_auth }
      before { @params = { uri: Settings.physical.uri } }

      it "should connect the physical device" do
        page.driver.put @uri, @params.to_json
        @resource.reload
        page.status_code.should == 200
        should_have_device @resource
        page.should have_content @params[:uri]
      end

      context "when exist physical device connection" do
        before { @resource = Factory(:device) }
        before { @uri =  "/devices/#{@resource.id.as_json}/physical" }
        before { @params = { uri: Settings.physical.another.uri } }

        it "should replace it" do
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

      it_validates "not valid JSON", "page.driver.put(@uri, @params.to_json)", "PUT"
    end
  end


  # ---------------------
  # DELETE /devices/:id
  # ---------------------
  #context ".destroy" do
    #before { @resource = Factory(:device) }
    #before { @uri =  "/devices/#{@resource.id.as_json}" }
    #before { @resource_not_owned = Factory(:device_not_owned) }

    #it_should_behave_like "not authorized resource", "page.driver.delete(@uri)"

    #context "when logged in" do
      #before { basic_auth } 

      #scenario "delete resource" do
        #expect{page.driver.delete(@uri, {}.to_json)}.to change{Device.count}.by(-1)
        #page.status_code.should == 200
        #should_have_device @resource
      #end

      #it_should_behave_like "a rescued 404 resource", "page.driver.delete(@uri)", "devices"
    #end
  #end

end
