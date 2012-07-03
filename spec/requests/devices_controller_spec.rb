require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "DevicesController" do
  before { Device.destroy_all }
  before { host! "http://" + host }

  # General stub
  before { stub_get(Settings.type.uri).to_return(body: fixture('type.json') ) }
  before { stub_get(Settings.type.another.uri).to_return(body: fixture('type.json') ) }



  # --------------
  # GET /devices
  # --------------
  context ".index" do
    before { @uri = "/devices" }
    before { @resource = FactoryGirl(:device) }
    before { @resource_not_owned = FactoryGirl(:device_not_owned) }

    it_should_behave_like "not authorized resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth }

      it "should view all owned resources" do
        visit @uri
        page.status_code.should == 200
        should_have_only_owned_device @resource
      end


      # ---------
      # Search
      # ---------
      context "when searching" do
        context "name" do
          before { @name = "My name is device" }
          before { @result = FactoryGirl(:device, name: @name) }

          it "should find a device" do
            visit "#{@uri}?name=name+is"
            should_contain_device @result
            page.should_not have_content @resource.name
          end
        end

        context "type_uri" do
          before { @type_uri = Settings.type.another.uri }
          before { @result = FactoryGirl(:device, type_uri: @type_uri)}

          it "should find a device" do
            visit "#{@uri}?type_uri=#{@type_uri}"
            should_contain_device @result
            page.should_not have_content @resource.type_uri
          end
        end

        context "property_uri" do
          before { @property_uri = Settings.properties.another.uri }
          before { @result = FactoryGirl(:device) }
          before { @result.device_properties.first.update_attributes(uri: @property_uri) }

          it "should filter the searched value" do
            visit "#{@uri}?property_uri=#{@property_uri}"
            should_contain_device @result
            page.should_not have_content @resource.device_properties.first.uri
          end
        end

        context "property_value" do
          before { @property_value = Settings.properties.another.value }
          before { @result = FactoryGirl(:device) }
          before { @result.device_properties.first.update_attributes(value: @property_value) }

          it "should filter the searched value" do
            visit "#{@uri}?property_value=#{@property_value}"
            should_contain_device @result
            page.should_not have_content @resource.device_properties.first.value
          end
        end

        # Property uri and property value belong to the same embedded property
        # In this case the search does match with a property
        context "property_uri and property_value" do
          before { @result = FactoryGirl(:device) }
          before { @property_uri = Settings.properties.another.uri }
          before { @property_value = Settings.properties.another.value }
          before { @result.device_properties.first.update_attributes(uri: @property_uri) }
          before { @result.device_properties.first.update_attributes(value: @property_value) }

          it "should filter the searched value" do
            visit "#{@uri}?property_uri=#{@property_uri}&property_value=#{@property_value}"
            should_contain_device @result
            page.should_not have_content @resource.device_properties.first.uri
            page.should_not have_content @resource.device_properties.first.value
          end
        end

        # Property uri and property value belong to two different embedded properties.
        # In this case the search does not match with any property.
        context "property_uri and property_value for different properties" do
          before { @property_uri = Settings.properties.another.uri }
          before { @property_value = Settings.properties.another.value }
          before { @result = FactoryGirl(:device) }
          before { @result.device_properties.first.update_attributes(uri: @property_uri) }
          before { @result.device_properties.first.update_attributes(value: @property_value) }

          it "should filter the searched value" do
            visit "#{@uri}?property_uri=#{Settings.properties.intensity.uri}&property_value=#{@property_value}"
            JSON.parse(page.source).should be_empty
          end
        end
      end


      # ------------
      # Pagination
      # ------------
      context "when paginating" do
        before { Device.destroy_all }
        before { @resource = DeviceDecorator.decorate(FactoryGirl(:device)) }
        before { @resources = FactoryGirlGirl.create_list(:device, Settings.pagination.per + 5, name: 'Extra dimmer') }

        context "with :start" do
          it "should show next page" do
            visit "#{@uri}?start=#{@resource.uri}"
            page.status_code.should == 200
            should_contain_device @resources.first
            page.should_not have_content @resource.name
          end
        end

        context "with :per" do
          it "should show the default number of resources" do
            visit "#{@uri}"
            JSON.parse(page.source).should have(Settings.pagination.per).items
          end

          it "should show 5 resources" do
            visit "#{@uri}?per=5"
            JSON.parse(page.source).should have(5).items
          end

          it "should show all resources" do
            visit "#{@uri}?per=all"
            JSON.parse(page.source).should have(Device.count).items
          end
        end
      end
    end
  end



  # ------------------
  # GET /devices/:id
  # ------------------
  context ".show" do
    before { @resource = DeviceDecorator.decorate(FactoryGirl(:device)) }
    before { @uri = "/devices/#{@resource.id.as_json}" }
    before { @resource_not_owned = FactoryGirl(:device_not_owned) }

    it_should_behave_like "not authorized resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth }

      it "should view owned resource" do
        visit @uri
        page.status_code.should == 200
        should_have_device @resource
      end

      it "should expose the device URI" do
        visit @uri
        uri = "http://www.example.com/devices/#{@resource.id.as_json}"
        @resource.uri.should == uri
      end

      context "with host" do
        it "should change the URI" do
          visit "#{@uri}?host=www.lelylan.com"
          @resource.uri.should match("http://www.lelylan.com/")
        end
      end

      it_should_behave_like "a rescued 404 resource", "visit @uri", "devices"
    end
  end



  # ---------------
  # POST /devices
  # ---------------
  context ".create" do
    before { @uri =  "/devices" }
    before { stub_get(Settings.type.uri).to_return(body: fixture('type.json')) }

    it_should_behave_like "not authorized resource", "page.driver.post(@uri)"

    context "when logged in" do
      before { basic_auth } 
      before { @params = { name: 'New closet dimmer', type_uri: Settings.type.uri, physical: {uri: Settings.physical.uri} } }

      it "should create a resource" do
        page.driver.post @uri, @params.to_json
        @resource = Device.last
        page.status_code.should == 201
        should_have_device @resource
      end

      context "when Lelylan Type" do
        context "returns unauthorized access" do
          before { @params[:type_uri] = @params[:type_uri] + "-401" }
          before { stub_get(@params[:type_uri]).to_return(status: 401, body: fixture('errors/401.json')) }

          it "should not create a resource" do
            page.driver.post @uri, @params.to_json
            code = 'notifications.type.unauthorized'
            should_have_a_not_valid_resource code: code, error: I18n.t(code)
          end
        end

        context "returns not found resource" do
          before { @params[:type_uri] = @params[:type_uri] + "-404" }
          before { stub_get(@params[:type_uri]).to_return(status: 404, body: fixture('errors/404.json')) }

          it "should not create a resource" do
            page.driver.post @uri, @params.to_json
            code = 'notifications.type.not_found'
            should_have_a_not_valid_resource code: code, error: I18n.t(code)
          end
        end

        context "returns technically wrong error" do
          before { @params[:type_uri] = @params[:type_uri] + "-500" }
          before { stub_get(@params[:type_uri]).to_return(status: 500, body: fixture('errors/500.json')) }

          it "should not create a resource" do
            page.driver.post @uri, @params.to_json
            code = 'notifications.type.error'
            should_have_a_not_valid_resource code: code, error: I18n.t(code)
          end
        end

        context "returns service over capacity" do
          before { @params[:type_uri] = @params[:type_uri] + "-503" }
          before { stub_get(@params[:type_uri]).to_return(status: 503, body: fixture('errors/503.json')) }

          it "should not create a resource" do
            page.driver.post @uri, @params.to_json
            code = 'notifications.type.unavailable'
            should_have_a_not_valid_resource code: code, error: I18n.t(code)
          end
        end
      end

      it_validates "not valid params", "page.driver.post(@uri, @params.to_json)", "POST"
      it_validates "not valid JSON", "page.driver.post(@uri, @params.to_json)", "POST"
    end
  end



  # ------------------
  # PUT /devices/:id
  # ------------------
  context ".update" do
    before { @resource = FactoryGirl(:device) }
    before { @uri = "/devices/#{@resource.id.as_json}" }
    before { @resource_not_owned = FactoryGirl(:device_not_owned) }

    it_should_behave_like "not authorized resource", "page.driver.put(@uri)"

    context "when logged in" do
      before { basic_auth }
      before { @params = { name: "Closet dimmer updated", physical: {uri: Settings.physical.uri + '-updated'} } }

      it "should update a resource" do
        page.driver.put @uri, @params.to_json
        @resource.reload
        page.status_code.should == 200
        page.should have_content "Closet dimmer updated"
        page.should have_content Settings.physical.uri + "-updated"
      end

      context "when changing type_uri" do
        it "should ignore type_uri" do
          @params[:type_uri] = Settings.type.another.uri
          page.driver.put @uri, @params.to_json
          page.should_not have_content Settings.type.another.uri
        end
      end

      it_should_behave_like "a rescued 404 resource", "page.driver.put(@uri)", "devices"
      it_validates "not valid JSON", "page.driver.put(@uri, @params.to_json)", "PUT"
    end
  end



  # ---------------------
  # DELETE /devices/:id
  # ---------------------
  context ".destroy" do
    before { @resource = FactoryGirl(:device) }
    before { @uri =  "/devices/#{@resource.id.as_json}" }
    before { @resource_not_owned = FactoryGirl(:device_not_owned) }

    it_should_behave_like "not authorized resource", "page.driver.delete(@uri)"

    context "when logged in" do
      before { basic_auth } 

      scenario "delete resource" do
        expect{page.driver.delete(@uri, {}.to_json)}.to change{Device.count}.by(-1)
        page.status_code.should == 200
        should_have_device @resource
      end

      it_should_behave_like "a rescued 404 resource", "page.driver.delete(@uri)", "devices"
    end
  end

end
