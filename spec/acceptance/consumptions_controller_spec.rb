require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "ConsumptionController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { Consumption.destroy_all }


  # GET /consumptions/
  context ".index" do
    before { @uri = "/consumptions?page=1&per=100" }
    before { @resource = Factory(:consumption) }
    before { @another_resource = Factory(:another_consumption) }
    before { @durational_resource = Factory(:durational_consumption) }
    before { @not_owned_resource = Factory(:not_owned_consumption) }

    it_should_behave_like "protected resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 

      scenario "view all resources" do
        visit @uri
        page.status_code.should == 200
        should_have_consumption(@resource)
        should_have_consumption(@durational_resource)
        should_have_consumption(@another_resource)
        should_not_have_consumption(@not_owned_resource)
        current_url.should_not match /type=/
        should_have_valid_json(page.body)
        should_have_root_as('resources')
      end

      scenario "view instantaneous resources" do
        visit "consumptions?type=instantaneous&page=1&per=100"
        page.status_code.should == 200
        should_have_consumption(@resource)
        page.should_not have_content @durational_resource.uri
        current_url.should match /type=instantaneous/
      end
      
      scenario "view durational resources" do
        visit "consumptions?type=durational&page=1&per=100"
        page.status_code.should == 200
        should_have_consumption(@durational_resource)
        page.should_not have_content @resource.uri
        current_url.should match /type=durational/
      end
    end
  end


  # GET /consumptions/{consumption-id}
  context ".show" do
    before { @not_owned_resource = Factory(:not_owned_device) }

    context "with 'instantaneous' consumption" do
      before { @resource = Factory(:consumption)}
      before { @uri = "/consumptions/#{@resource.id.as_json}" }
      it_should_behave_like "protected resource", "visit(@uri)"

      context "when logged in" do
        before { basic_auth(@user) } 
        scenario "view owned resource" do
          visit @uri
          page.should have_content 'instantaneous'
          page.status_code.should == 200
          should_have_consumption(@resource)
          should_have_valid_json(page.body)
        end

        it_should_behave_like "rescued when not found", 
                              "visit @uri", "devices"
     end
    end
    
    context "with 'durational' consumption" do
      before { @resource = Factory(:durational_consumption)}
      before { @uri = "/consumptions/#{@resource.id.as_json}" }
      it_should_behave_like "protected resource", "visit(@uri)"

      context "when logged in" do
        before { basic_auth(@user) } 

        scenario "view owned resource" do
          visit @uri
          page.status_code.should == 200
          page.should have_content 'durational'
          should_have_consumption(@resource)
          should_have_valid_json(page.body)
        end

        it_should_behave_like "rescued when not found", 
                              "visit @uri", "devices"
      end
    end
  end

  
  
  # GET /devices/{device-id}/consumptions
  # GET /devices/{device-id}/consumptions?type=instantaneous
  # GET /devices/{device-id}/consumptions?type=durational
  context ".show" do
    context "restricted to a device" do
      before { @resource = Factory(:device) }
      before { @not_owned_resource = Factory(:not_owned_device) }
      before { @uri = "#{host}/devices/#{@resource.id}" }
      before { @consumption = Factory(:consumption) }
      before { @another_consumption = Factory(:another_consumption) }
      before { @durational_consumption = Factory(:durational_consumption) }
      before { @another_durational_consumption = Factory(:another_durational_consumption) }
      
      it_should_behave_like "protected resource", "visit(@uri)"

      context "when logged in" do
        before { basic_auth(@user) } 

        scenario "view all resources" do
          visit "#{@uri}/consumptions?page=1&per=100"
          page.status_code.should == 200
          should_have_consumption(@consumption)
          page.should_not have_content @another_consumption.device_uri
          should_have_valid_json(page.body)
        end

        scenario "view instantaneous resources" do
          visit "#{@uri}/consumptions?type=instantaneous&page=1&per=100"
          page.status_code.should == 200
          should_have_consumption(@consumption)
          page.should_not have_content @another_consumption.device_uri
        end
        
        scenario "view durational resources" do
          visit "#{@uri}/consumptions?type=durational&page=1&per=100"
          page.status_code.should == 200
          should_have_consumption(@durational_consumption)
          page.should_not have_content @another_durational_consumption.device_uri
        end

        it_should_behave_like "rescued when not found", 
                              "visit @uri", "devices", "consumptions"
      end
    end
  end


  # POST /consumption
  context ".create" do
    before { @uri =  "/consumptions/" }
    it_should_behave_like "protected resource", "page.driver.post(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 

      context "with 'instantaneous' type" do
        let(:params) {{ 
          device_uri: Settings.device.uri,
          type: 'instantaneous',
          consumption: '1.25',
          unit: 'kwh',
          occur_at: Time.now
        }}

        scenario "creates 'instantaneous' resource" do
          page.driver.post(@uri, params.to_json)
          @resource = Consumption.last
          page.status_code.should == 201
          should_have_consumption(@resource)
          should_have_valid_json(page.body)
        end
      end

      context "with 'durational' type" do
        let(:params) {{ 
          device_uri: Settings.device.uri,
          type: 'durational',
          consumption: '1.25',
          unit: 'kwh',
          occur_at: Time.now,
          duration: 60
        }}

        scenario "creates 'istantaneous' resource" do
          page.driver.post(@uri, params.to_json)
          @resource = Consumption.last
          page.status_code.should == 201
          should_have_consumption(@resource)
          page.should have_content (@resource.occur_at + 60).to_s
          should_have_valid_json(page.body)
        end
      end

      scenario "not valid params" do
        page.driver.post(@uri, {}.to_json)
        should_have_a_not_valid_resource
        should_have_valid_json(page.body)
      end
    end
  end

  
  # DELETE /consumptions/{consumption-id}
  context ".destroy" do
    before { @resource = Factory(:consumption) }
    before { @uri =  "/consumptions/#{@resource.id.as_json}" }
    before { @not_owned_resource = Factory(:not_owned_consumption) }

    it_should_behave_like "protected resource", "page.driver.delete(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      scenario "delete resource" do
        lambda {
          page.driver.delete(@uri, {}.to_json)
        }.should change{ Consumption.count }.by(-1)
        page.status_code.should == 200
        should_have_consumption(@resource)
        should_have_valid_json(page.body)
      end

      it_should_behave_like "rescued when not found",
        "page.driver.delete(@uri)", "devices"
    end
  end
end
