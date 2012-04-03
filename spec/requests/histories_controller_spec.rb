require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "HistoriesController" do
  before { Device.destroy_all }
  before { History.destroy_all }
  before { host! "http://" + host }

  # General stub
  before { stub_get(Settings.type.uri).to_return(body: fixture('type.json') ) }
  before { stub_get(Settings.type.another.uri).to_return(body: fixture('type.json') ) }


  # ----------------------------
  # GET /devices/:id/histories
  # ----------------------------
  context ".index" do
    before { @device = Factory(:device) }
    before { @device_uri = "#{host}/devices/#{@device.id.as_json}" }
    before { @resource = Factory(:history, device_uri: @device_uri) }
    before { @uri = "/devices/#{@device.id.as_json}/histories" }
    before { @resource_not_owned = Factory(:history_not_owned) }

    it_should_behave_like "not authorized resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth }

      it "should view all resources" do
        visit @uri
        page.status_code.should == 200
        should_have_only_owned_history @resource
      end


      ## ---------
      ## Search
      ## ---------
      #context "when searching" do
        #context "name" do
          #before { @name = "My name is device" }
          #before { @result = Factory(:device, name: @name) }

          #it "should find a device" do
            #visit "#{@uri}?name=name+is"
            #should_contain_device @result
            #page.should_not have_content @resource.name
          #end
        #end

        #context "type_uri" do
          #before { @type_uri = Settings.type.another.uri }
          #before { @result = Factory(:device, type_uri: @type_uri)}

          #it "should find a device" do
            #visit "#{@uri}?type_uri=#{@type_uri}"
            #should_contain_device @result
            #page.should_not have_content @resource.type_uri
          #end
        #end

        #context "property_uri" do
          #before { @property_uri = Settings.properties.another.uri }
          #before { @result = Factory(:device) }
          #before { @result.device_properties.first.update_attributes(uri: @property_uri) }

          #it "should filter the searched value" do
            #visit "#{@uri}?property_uri=#{@property_uri}"
            #should_contain_device @result
            #page.should_not have_content @resource.device_properties.first.uri
          #end
        #end

        #context "property_value" do
          #before { @property_value = Settings.properties.another.value }
          #before { @result = Factory(:device) }
          #before { @result.device_properties.first.update_attributes(value: @property_value) }

          #it "should filter the searched value" do
            #visit "#{@uri}?property_value=#{@property_value}"
            #should_contain_device @result
            #page.should_not have_content @resource.device_properties.first.value
          #end
        #end

        ## Property uri and property value belong to the same embedded property
        ## In this case the search does match with a property
        #context "property_uri and property_value" do
          #before { @result = Factory(:device) }
          #before { @property_uri = Settings.properties.another.uri }
          #before { @property_value = Settings.properties.another.value }
          #before { @result.device_properties.first.update_attributes(uri: @property_uri) }
          #before { @result.device_properties.first.update_attributes(value: @property_value) }

          #it "should filter the searched value" do
            #visit "#{@uri}?property_uri=#{@property_uri}&property_value=#{@property_value}"
            #should_contain_device @result
            #page.should_not have_content @resource.device_properties.first.uri
            #page.should_not have_content @resource.device_properties.first.value
          #end
        #end

        ## Property uri and property value belong to two different embedded properties.
        ## In this case the search does not match with any property.
        #context "property_uri and property_value for different properties" do
          #before { @property_uri = Settings.properties.another.uri }
          #before { @property_value = Settings.properties.another.value }
          #before { @result = Factory(:device) }
          #before { @result.device_properties.first.update_attributes(uri: @property_uri) }
          #before { @result.device_properties.first.update_attributes(value: @property_value) }

          #it "should filter the searched value" do
            #visit "#{@uri}?property_uri=#{Settings.properties.intensity.uri}&property_value=#{@property_value}"
            #JSON.parse(page.source).should be_empty
          #end
        #end
      #end


      ## ------------
      ## Pagination
      ## ------------
      #context "when paginating" do
        #before { Device.destroy_all }
        #before { @resource = DeviceDecorator.decorate(Factory(:device)) }
        #before { @resources = FactoryGirl.create_list(:device, Settings.pagination.per + 5, name: 'Extra dimmer') }

        #context "with :start" do
          #it "should show next page" do
            #visit "#{@uri}?start=#{@resource.uri}"
            #page.status_code.should == 200
            #should_contain_device @resources.first
            #page.should_not have_content @resource.name
          #end
        #end

        #context "with :per" do
          #it "should show the default number of resources" do
            #visit "#{@uri}"
            #JSON.parse(page.source).should have(Settings.pagination.per).items
          #end

          #it "should show 5 resources" do
            #visit "#{@uri}?per=5"
            #JSON.parse(page.source).should have(5).items
          #end

          #it "should show all resources" do
            #visit "#{@uri}?per=all"
            #JSON.parse(page.source).should have(Device.count).items
          #end
        #end
      #end
    end
  end

end
