require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "ConsumptionsController" do
  before { Device.destroy_all }
  before { Consumption.destroy_all }
  before { host! "http://" + host }

  before { stub_get(Settings.type.uri).to_return(body: fixture('type.json') ) }
  before { stub_get(Settings.type.another.uri).to_return(body: fixture('type.json') ) }

  before { @device = Factory(:device) }
  before { @device_uri = "#{host}/devices/#{@device.id.as_json}" }
  before { @occur_at = Chronic.parse('1 week ago') }
  before { @resource = ConsumptionDecorator.decorate(Factory(:consumption, device_uri: @device_uri, occur_at: @occur_at)) }
  before { @resource_not_owned = Factory(:consumption_not_owned) }


  # ------------------------------
  # GET /devices/:id/consumptions
  # ------------------------------
  context ".index" do
   before { @uri = "/devices/#{@device.id.as_json}/consumptions" }

    it_should_behave_like "not authorized resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth }

      it "should view all owned resources" do
        visit @uri
        page.status_code.should == 200
        should_have_only_owned_consumption @resource
      end


      # ---------
      # Search
      # ---------
      context "when searching" do
        before { @result = Factory(:consumption, device_uri: @device_uri) }

        context "with :from" do
          it "should find a consumption" do
            visit "#{@uri}?from=yesterday"
            should_contain_consumption @result
            JSON.parse(page.source).should have(1).item
          end

          it "should find all device consumptions" do
            visit "#{@uri}?from=one+year+ago"
            should_contain_consumption @resource
            JSON.parse(page.source).should have(2).item
          end
        end

        context "with :to" do
          it "should find a consumption " do
            visit "#{@uri}?to=yesterday"
            should_contain_consumption @resource
            JSON.parse(page.source).should have(1).item
          end

          it "should not find consumptions" do
            visit "#{@uri}?to=one+year+ago"
            JSON.parse(page.source).should be_empty
          end
        end

        context "with :from and :to" do
          it "should find a consumption" do
            visit "#{@uri}?from=two+weeks+ago&to=yesterday"
            should_contain_consumption @resource
            JSON.parse(page.source).should have(1).item
          end
        end

        context "with :type" do
          before { @durational = Factory(:consumption_durational, device_uri: @device_uri) }

          context "when :type is instantaneous" do
            it "should find an instantaneous consumption" do
              visit "#{@uri}?type=instantaneous"
              should_contain_consumption @resource
              page.should_not have_content 'durational' 
            end
          end

          context "when :type is durational" do
            it "should find a durational consumption" do
              visit "#{@uri}?type=durational"
              should_contain_consumption @durational
              JSON.parse(page.source).should have(1).item
              page.should_not have_content 'instantaneous' 
            end
          end
        end

        context "with :unit" do
          before { @result = Factory(:consumption_durational, device_uri: @device_uri, unit: 'unit') }

          it "should find a consumption" do
            visit "#{@uri}?unit=unit"
            should_contain_consumption @result
            page.should_not have_content 'KWH'
          end
        end
      end


      # ------------
      # Pagination
      # ------------
      context "when paginating" do
        before { Consumption.destroy_all }
        before { @created_at = Chronic.parse('1 week ago') }
        before { @resource = ConsumptionDecorator.decorate(Factory(:consumption, device_uri: @device_uri, value: '0.175')) }
        before { @resources = FactoryGirl.create_list(:consumption, Settings.pagination.per + 5, device_uri: @device_uri) }

        context "with :start" do
          it "should show next resources" do
            visit "#{@uri}?start=#{@resource.uri}"
            page.status_code.should == 200
            should_contain_consumption @resources.first
            page.should_not have_content @resource.value
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
            JSON.parse(page.source).should have(Consumption.count).items
          end
        end
      end
    end
  end


  # ------------------
  # GET /consumptions
  # ------------------
  context ".index" do
    before { @uri = "/consumptions" }
    before { @device = Factory(:device) }
    before { @device_uri = "#{host}/devices/#{@device.id.as_json}" }
    before { @another_resource = ConsumptionDecorator.decorate(Factory(:consumption, device_uri: @device_uri, occur_at: @occur_at)) }

    it_should_behave_like "not authorized resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth }

      it "should view all resources" do
        visit @uri
        page.status_code.should == 200
        JSON.parse(page.source).should have(2).item
      end
    end
  end


  # -----------------------
  # GET /consumptions/:id
  # -----------------------
  context ".show" do
    before { @uri = "/consumptions/#{@resource.id.as_json}" }

    it_should_behave_like "not authorized resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth }

      it "should view owned resource" do
        visit @uri
        page.status_code.should == 200
        should_have_consumption @resource
      end

      it "should expose the consumption URI" do
        visit @uri
        uri = "http://www.example.com/consumptions/#{@resource.id.as_json}"
        @resource.uri.should == uri
      end

      context "with :host" do
        it "should change the URI" do
          visit "#{@uri}?host=www.lelylan.com"
          @resource.uri.should match("http://www.lelylan.com/")
        end
      end

      it_should_behave_like "a rescued 404 resource", "visit @uri", "devices"
    end
  end

  
  # -------------------
  # POST /consumptions
  # -------------------
  context ".create" do
    before { @uri =  "/consumptions" }
    before { @device = Factory(:device) }
    before { @device_uri = "#{host}/devices/#{@device.id.as_json}" }
 
    it_should_behave_like "not authorized resource", "page.driver.post(@uri)"

    context "when logged in" do
      before { basic_auth } 
      before { @params = { device_uri: @device_uri, value: "10.0" } }

      context "without :type" do
        it "should create an instantaneous consupmtion" do
          page.driver.post @uri, @params.to_json
          @resource = Consumption.last
          page.status_code.should == 201
          should_have_consumption @resource
          page.should have_content "instantaneous"
        end
      end

      context "with durational :type" do
        before { @params.merge!({type: 'durational', occur_at: Time.now-60, end_at: Time.now}) }

        it "should create a durational consuption" do
          page.driver.post @uri, @params.to_json
          @resource = Consumption.last
          page.status_code.should == 201
          should_have_consumption @resource
          page.should have_content "durational"
          page.should have_content "60"
        end
      end

      it_validates "not valid params", "page.driver.post(@uri, @params.to_json)", "POST"
      it_validates "not valid JSON", "page.driver.post(@uri, @params.to_json)", "POST"
    end
  end


  # -----------------------
  # PUT /consumptions/:id
  # -----------------------
  context ".update" do
    before { @uri = "/consumptions/#{@resource.id.as_json}" }

    it_should_behave_like "not authorized resource", "page.driver.put(@uri)"

    context "when logged in" do
      before { basic_auth }
      before { @params = { value: "0.00" } }

      it "should update a resource" do
        page.driver.put @uri, @params.to_json
        @resource.reload
        page.status_code.should == 200
        page.should have_content "0.00"
        page.should_not have_content "125"
      end

      context "when params are not valid" do
        it "should not update the resource" do
          @params[:type] = "not-existing"
          page.driver.put @uri, @params.to_json
          page.status_code.should == 422
          should_have_a_not_valid_resource error: 'is not included in the list', method: 'PUT'
        end
      end

      it_should_behave_like "a rescued 404 resource", "page.driver.put(@uri)", "devices"
      it_validates "not valid JSON", "page.driver.put(@uri, @params.to_json)", "PUT"
    end
  end
  

  # --------------------------
  # DELETE /consumptions/:id
  # --------------------------
  context ".destroy" do
    before { @uri = "/consumptions/#{@resource.id.as_json}" }
 
    it_should_behave_like "not authorized resource", "page.driver.delete(@uri)"

    context "when logged in" do
      before { basic_auth } 

      scenario "delete resource" do
        expect{page.driver.delete(@uri, {}.to_json)}.to change{Consumption.count}.by(-1)
        page.status_code.should == 200
        should_have_consumption @resource
      end

      it_should_behave_like "a rescued 404 resource", "page.driver.delete(@uri)", "consumptions"
    end
  end
end
