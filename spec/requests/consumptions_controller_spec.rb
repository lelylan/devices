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

      it "should view all resources" do
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
      end


      ## ------------
      ## Pagination
      ## ------------
      #context "when paginating" do
        #before { History.destroy_all }
        #before { @created_at = Chronic.parse('1 week ago') }
        #before { @resource = HistoryDecorator.decorate(Factory(:history, device_uri: @device_uri, created_at: @created_at)) }
        #before { @resources = FactoryGirl.create_list(:history, Settings.pagination.per + 5, device_uri: @device_uri) }

        #context "with :start" do
          #it "should show next resources" do
            #visit "#{@uri}?start=#{@resource.uri}"
            #page.status_code.should == 200
            #should_contain_history @resources.first
            #page.should_not have_content @resource.created_at.strftime("%Y-%m-%d")
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
            #JSON.parse(page.source).should have(History.count).items
          #end
        #end
      #end
    end
  end


  ## -------------------
  ## GET /histories/:id
  ## -------------------
  #context ".show" do
    #before { @uri = "/histories/#{@resource.id.as_json}" }

    #it_should_behave_like "not authorized resource", "visit(@uri)"

    #context "when logged in" do
      #before { basic_auth }

      #it "should view owned resource" do
        #visit @uri
        #page.status_code.should == 200
        #should_have_history @resource
      #end

      #it "should expose the history URI" do
        #visit @uri
        #uri = "http://www.example.com/histories/#{@resource.id.as_json}"
        #@resource.uri.should == uri
      #end

      #context "with :host" do
        #it "should change the URI" do
          #visit "#{@uri}?host=www.lelylan.com"
          #@resource.uri.should match("http://www.lelylan.com/")
        #end
      #end

      #it_should_behave_like "a rescued 404 resource", "visit @uri", "devices"
    #end
  #end
end
