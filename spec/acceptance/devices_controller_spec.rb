require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "DevicesController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { Device.destroy_all }


  # GET /devices
  context ".index" do
    before { @uri = "/devices?page=1&per=100" }
    before { @resource = Factory(:device) }
    before { @not_owned_resource = Factory(:not_owned_device) }

    it_should_behave_like "protected resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      scenario "view all resources" do
        visit @uri
        page.status_code.should == 200
        should_have_device(@resource)
        should_not_have_device(@not_owned_resource)
        should_have_valid_json(page.body)
        should_have_root_as('devices')
      end
    end
  end


  # GET /devices/{device-id}
  context ".show" do
    before { @resource = Factory(:device) }
    before { @uri = "/devices/#{@resource.id.as_json}" }
    before { @not_owned_resource = Factory(:not_owned_device) }

    it_should_behave_like "protected resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      scenario "view owned resource" do
        visit @uri
        page.status_code.should == 200
        should_have_device(@resource)
        should_have_valid_json(page.body)
      end

      it_should_behave_like "rescued when not found", 
                            "visit @uri", "devices"
    end
  end


  # POST /devices
  context ".create" do
    before { @uri =  "/devices/" }

    it_should_behave_like "protected resource", "page.driver.post(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      let(:params) {{ 
        name: Settings.type.name,
        type_uri: Settings.type.uri 
      }}

      scenario "create resource" do
        page.driver.post(@uri, params.to_json)
        @resource = Device.last
        page.status_code.should == 201
        should_have_device(@resource)
        should_have_device_properties(@resource.device_properties)
        should_have_device_functions(@resource.device_functions)
        should_have_valid_json(page.body)
      end

      scenario "not valid params" do
        page.driver.post(@uri, {}.to_json)
        should_have_a_not_valid_resource
      end
    end
  end


  # PUT /devices/{device-id}
  # TODO: Add a test when you update a device with another type 
  # uri. Another solution is that type can not be updated, and 
  # that in that case you probably want to create a new device.
  context ".update" do
    before { @resource = Factory(:device) }
    before { @uri =  "/devices/#{@resource.id.as_json}" }
    before { @not_owned_resource = Factory(:not_owned_device) }

    it_should_behave_like "protected resource", "page.driver.put(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      let(:params) {{ 
        name: "Set intensity updated",
        type_uri: Settings.type.uri
      }}

      scenario "create resource" do
        page.driver.put(@uri, params.to_json)
        page.status_code.should == 200
        should_have_device(@resource.reload)
        page.should have_content "updated"
        should_have_device_properties(@resource.device_properties)
        should_have_device_functions(@resource.device_functions)
        should_have_valid_json(page.body)
      end

      scenario "not valid params" do
        params[:type_uri] = "not-an-uri"
        page.driver.put(@uri, params.to_json)
        should_have_a_not_valid_resource
      end

      it_should_behave_like "rescued when not found",
        "page.driver.put(@uri)", "devices"
    end
  end


  # DELETE /devices/{device-id}
  context ".destroy" do
    before { @resource = Factory(:device) }
    before { @uri =  "/devices/#{@resource.id.as_json}" }
    before { @not_owned_resource = Factory(:not_owned_device) }

    it_should_behave_like "protected resource", "page.driver.delete(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      scenario "delete resource" do
        lambda {
          page.driver.delete(@uri, {}.to_json)
          page.status_code.should == 204
        }.should change{ Device.count }.by(-1)
      end

      it_should_behave_like "rescued when not found",
        "page.driver.delete(@uri)", "devices"
    end
  end

end
