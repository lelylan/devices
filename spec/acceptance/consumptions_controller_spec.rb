require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "ConsumptionController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { Consumption.destroy_all }


  # GET /consumptions/
  context ".index" do
    before { @uri = "/consumptions?page=1&per=100" }
    before { @resource = Factory(:consumption) }
    before { @other_resource = Factory(:durational_consumption) }
    before { @not_owned_resource = Factory(:not_owned_consumption) }

    it_should_behave_like "protected resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 

      scenario "view all resources" do
        visit @uri
        page.status_code.should == 200
        should_have_consumption(@resource)
        should_have_consumption(@other_resource)
        should_not_have_consumption(@not_owned_resource)
        should_have_valid_json(page.body)
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
          page.status_code.should == 204
        }.should change{ Consumption.count }.by(-1)
      end

      it_should_behave_like "rescued when not found",
        "page.driver.delete(@uri)", "devices"
    end
  end
end
