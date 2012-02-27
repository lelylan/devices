require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "DevicesController" do
  before { Device.destroy_all }



  # --------------
  # GET /devices
  # --------------
  context ".index" do
    before { @uri = "/devices" }
    before { @resource = Factory(:device) }
    before { @resource_not_owned = Factory(:device_not_owned) }

    it_should_behave_like "not authorized resource", "visit(@uri)"


    context "when logged in" do
      before { basic_auth }

      scenario "view all resources" do
        visit @uri
        page.status_code.should == 200
        should_have_valid_json
        should_have_only_owned_device @resource
      end


      context "when searching" do
        context "name" do
          before { @name = "My name is device" }
          before { @result = Factory(:device, name: @name) }

          it "should find a device" do
            visit "#{@uri}?name=name+is"
            should_contain_device @result
            page.should_not have_content @resource.name
          end
        end

        context "type_uri" do
          before { @type_uri = Settings.type.another.uri }
          before { @result = Factory(:device, type_uri: @type_uri)}

          it "should find a device" do
            visit "#{@uri}?type_uri=#{@type_uri}"
            should_contain_device @result
            page.should_not have_content @resource.type_uri
          end
        end

        context "property_uri" do
          before { @property_uri = Settings.properties.another.uri }
          before { @result = Factory(:device) }
          before { @result.device_properties.first.update_attributes(uri: @property_uri) }

          it "should filter the searched value" do
            visit "#{@uri}?property_uri=#{@property_uri}"
            should_contain_device @result
            page.should_not have_content @resource.device_properties.first.uri
          end
        end

        context "property_name" do
          before { @property_value = Settings.properties.another.uri }
          before { @result = Factory(:device) }
          before { @result.device_properties.first.update_attributes(value: @property_value) }

          it "should filter the searched value" do
            visit "#{@uri}?property_value=#{@property_value}"
            should_contain_device @result
            page.should_not have_content @resource.device_properties.first.value
          end
        end
      end


      context "when paginating" do
        before { Device.destroy_all }
        before { @resource = Factory(:device) }
        before { @resources = FactoryGirl.create_list(:device, Settings.pagination.per + 5, uri: Settings.device.another.uri) }

        context "with :from" do
          scenario "should show next page" do
            visit "#{@uri}?from=#{@resource.uri}"
            page.status_code.should == 200
            should_have_valid_json
            should_contain_device @resources.first
            page.should_not have_content @resource.uri
          end
        end

        context "with :per" do
          scenario "show the default number of resources" do
            visit "#{@uri}"
            JSON.parse(page.source).should have(Settings.pagination.per).items
          end

          scenario "show 5 resources" do
            visit "#{@uri}?per=5"
            JSON.parse(page.source).should have(5).items
          end

          scenario "show all resources" do
            visit "#{@uri}?per=all"
            JSON.parse(page.source).should have(Device.count).items
            JSON.parse(page.source).should_not have(Settings.pagination.per).items
          end
        end
      end
    end
  end



  # ------------------
  # GET /devices/:id
  # ------------------
  context ".show" do
    before { @resource = Factory(:device) }
    before { @uri = "/devices/#{@resource.id.as_json}" }
    before { @resource_not_owned = Factory(:device_not_owned) }

    it_should_behave_like "not authorized resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth }

      scenario "view owned resource" do
        visit @uri
        page.status_code.should == 200
        should_have_valid_json
        should_have_device @resource
      end

      it_should_behave_like "a rescued 404 resource", "visit @uri", "devices"
    end
  end

end
