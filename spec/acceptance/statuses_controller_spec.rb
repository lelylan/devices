require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "StatusesController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { @resource = Factory(:device_complete) }
  before { @not_owned_resource = Factory(:not_owned_device) }
  before { @not_owned_resource = Factory(:not_owned_device) }
  before { @intensity_uri = Settings.properties.intensity.uri }


  # GET /devices/{device-id}/status
  context ".show" do
    before { @uri = "/devices/#{@resource.id.as_json}/status" }
    it_should_behave_like "protected resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth(@user) }

      # ------------
      # With values
      # ------------

      #context "with values populated" do
        #context "whit intensity to 0.0" do
          #context "with intensity pending to false" do
            #scenario "should have 'has set intensity' status" do
              #visit(@uri)
              #page.status_code.should == 200
              #page.should have_content Settings.statuses.has_set_intensity.uri
              #should_have_valid_json(page.body)
            #end

            #context "with intensity pending to true" do
              #before do
                #@resource.device_properties.where(uri: Settings.properties.intensity.uri).first.pending = true
                #@resource.save 
              #end
              #scenario "should have 'has set intensity' status" do
                #visit(@uri)
                #page.status_code.should == 200
                #page.should have_content Settings.statuses.is_setting_intensity.uri
                #should_have_valid_json(page.body)
              #end
            #end
          #end
        #end

        #context "with intensity to 10.0" do
          #before do
            #@resource.device_properties.where(uri: Settings.properties.intensity.uri).first.value = '10.0'
            #@resource.save 
          #end

          #context "with intensity pending to false" do
            #scenario "should have 'has set intensity' status" do
              #visit(@uri)
              #page.status_code.should == 200
              #page.should have_content Settings.statuses.has_set_max.uri
              #should_have_valid_json(page.body)
            #end

            #context "with intensity pending to true" do
              #before do
                #@resource.device_properties.where(uri: Settings.properties.intensity.uri).first.pending = true
                #@resource.save 
              #end

              #scenario "should have 'has set intensity' status" do
                #visit(@uri)
                #page.status_code.should == 200
                #page.should have_content Settings.statuses.is_setting_max.uri
                #should_have_valid_json(page.body)
              #end
            #end
          #end
        #end

        #context "with intensity to 10000.0 (not valid)" do
          #before do
            #@resource.device_properties.where(uri: Settings.properties.intensity.uri).first.value = '10000.0'
            #@resource.save 
          #end

          #scenario "should have 'default' status" do
            #visit(@uri)
            #page.status_code.should == 200
            #page.should have_content Settings.statuses.default.uri
            #should_have_valid_json(page.body)
          #end
        #end
      #end

      # ------------
      # With range
      # ------------

      context "with range populated" do
        before { @resource = Factory(:device_range_complete) }
        before { @uri = "/devices/#{@resource.id.as_json}/status" } 

        context "whit intensity to 0.0" do
          context "with intensity pending to false" do
            scenario "should have 'has set intensity' status" do
              visit(@uri)
              save_and_open_page
              page.status_code.should == 200
              page.should have_content Settings.statuses.has_set_intensity.uri
              should_have_valid_json(page.body)
            end

            #context "with intensity pending to true" do
              #before do
                #@resource.device_properties.where(uri: Settings.properties.intensity.uri).first.pending = true
                #@resource.save 
              #end
              #scenario "should have 'has set intensity' status" do
                #visit(@uri)
                #page.status_code.should == 200
                #page.should have_content Settings.statuses.is_setting_intensity.uri
                #should_have_valid_json(page.body)
              #end
            #end
          end
        end

        #context "with intensity to 10.0" do
          #before do
            #@resource.device_properties.where(uri: Settings.properties.intensity.uri).first.value = '10.0'
            #@resource.save 
          #end

          #context "with intensity pending to false" do
            #scenario "should have 'has set intensity' status" do
              #visit(@uri)
              #page.status_code.should == 200
              #page.should have_content Settings.statuses.has_set_max.uri
              #should_have_valid_json(page.body)
            #end

            #context "with intensity pending to true" do
              #before do
                #@resource.device_properties.where(uri: Settings.properties.intensity.uri).first.pending = true
                #@resource.save 
              #end

              #scenario "should have 'has set intensity' status" do
                #visit(@uri)
                #page.status_code.should == 200
                #page.should have_content Settings.statuses.is_setting_max.uri
                #should_have_valid_json(page.body)
              #end
            #end
          #end
        #end

        #context "with intensity to 10000.0 (not valid)" do
          #before do
            #@resource.device_properties.where(uri: Settings.properties.intensity.uri).first.value = '10000.0'
            #@resource.save 
          #end

          #scenario "should have 'default' status" do
            #visit(@uri)
            #page.status_code.should == 200
            #page.should have_content Settings.statuses.default.uri
            #should_have_valid_json(page.body)
          #end
        #end
      end

      #context ".png" do
        #before { basic_auth(@user) }
        #before { @uri = "#{host}#{@uri}.png" }
        #scenario "should redirect to image uri" do
          #lambda {
            #visit(@uri)
          #}.should raise_error(ActionController::RoutingError)
        #end
      #end
    end
  end
end
