require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "DevicesController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { Device.destroy_all }


  # GET /devices
  context ".index" do
    before { @uri = "/devices" }
    before { @resource = Factory(:device_complete) }
    before { @not_owned_resource = Factory(:not_owned_device) }

    it_should_behave_like "protected resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      scenario "view all resources" do
        visit @uri
        page.status_code.should == 200
        should_have_device(@resource)
        should_not_have_device(@not_owned_resource)
        should_have_pagination(@uri)
        should_have_valid_json(page.body)
        should_have_root_as('resources')
      end

      context "with filter" do
        context "params[:name]" do
          before { @to_search = "A new cool name" }
          before { @filtered_resource = Factory(:device_complete, name: @to_search) }
          before { visit "#{@uri}?name=A+new" }
          it "should filter the searched value" do
            should_have_device(@filtered_resource)
            page.should_not have_content @resource.name
          end
        end

        context "params[:type]" do
          before { @to_search = Settings.another_type.uri }
          before { @filtered_resource = Factory(:device_complete, type_uri: @to_search)}
          before { visit "#{@uri}?type=#{@to_search}" }
          it "should filter the searched value" do
            should_have_device(@filtered_resource)
            page.should_not have_content @resource.type_uri
          end
        end

        context "params[:type_name]" do
          before { @to_search = "A new cool name" }
          before { @filtered_resource = Factory(:device_complete, type_name: @to_search)}
          before { visit "#{@uri}?type_name=A+new" }
          it "should filter the searched value" do
            should_have_device(@filtered_resource)
            page.should_not have_content @resource.type_name
          end
        end

        context "params[:category]" do
          before { @to_search = Settings.another_category.uri }
          before { @filtered_resource = Factory(:device_complete) }
          before { @filtered_resource.device_categories.first.update_attributes(uri: @to_search) }
          before { visit "#{@uri}?category=#{@to_search}" }
          it "should filter the searched value" do
            should_have_device(@filtered_resource)
            page.should_not have_content @resource.device_categories.first.uri
          end
        end
        
        context "params[:category_name]" do
          before { @to_search = "A new cool name" }
          before { @filtered_resource = Factory(:device_complete) }
          before { @filtered_resource.device_categories.first.update_attributes(name: @to_search) }
          before { visit "#{@uri}?category_name=A+new" }
          it "should filter the searched value" do
            should_have_device(@filtered_resource)
            page.should_not have_content @resource.device_categories.first.name
          end
        end
      end
    end
  end


  # GET /devices/{device-id}
  context ".show" do
    before { @resource = Factory(:device_complete) }
    before { @uri = "/devices/#{@resource.id.as_json}" }
    before { @not_owned_resource = Factory(:not_owned_device) }

    it_should_behave_like "protected resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      scenario "view owned resource" do
        visit @uri
        page.status_code.should == 200
        should_have_device(@resource)
        should_have_device_connections(@resource)
        should_have_valid_json(page.body)
      end
      
      context "with format .png" do
        before { basic_auth(@user) }
        before { @uri = "#{@uri}.png" }
        scenario "should redirect to status image uri" do
          lambda {
            visit(@uri)
          }.should raise_error(ActionController::RoutingError)
        end
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
        should_have_device_connections(@resource)
        should_have_valid_json(page.body)
      end

      scenario "not valid params" do
        page.driver.post(@uri, {}.to_json)
        should_have_a_not_valid_resource
        should_have_valid_json(page.body)
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
        }.should change{ Device.count }.by(-1)
        page.status_code.should == 200
        should_have_device(@resource)
        should_have_valid_json(page.body)
      end

      it_should_behave_like "rescued when not found",
        "page.driver.delete(@uri)", "devices"
    end
  end

end
