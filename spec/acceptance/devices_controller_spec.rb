require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "DevicesController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }

  # /devices/
  context ".index" do
    before { @uri = "/devices" }
    before { @device = Factory(:device) }
    before { @not_owned_device = Factory(:not_owned_device) }

    context "when not logged in" do
      before { basic_auth_cleanup }
      scenario "is not authorized" do
        visit @uri
        should_not_be_authorized
      end
    end

    context "when logged in" do
      before { basic_auth(@user) } 
      scenario "view all resources" do
        visit @uri
        page.status_code.should == 200
        should_have_device(@device)
        should_not_have_device(@not_owned_device)
      end
      
    end
  end

  # /devices/{device-id}
  context ".show" do
    before { @device = Factory(:device) }
    before { @uri =  "/devices/#{@device.id.as_json}" }
    before { @not_owned_device = Factory(:not_owned_device) }

    context "when not logged in" do
      before { basic_auth_cleanup }
      scenario "is not authorized" do
        visit @uri
        should_not_be_authorized
      end
    end

    context "when logged in" do
      before { basic_auth(@user) } 

      scenario "view owned resource" do
        visit @uri
        page.status_code.should == 200
        should_have_device(@device)
      end

      context "with not existing resource" do
        scenario "is not found" do
          @device.destroy
          visit @uri
          should_have_a_not_found_resource(@uri)
        end
      end

      context "with not owned resource" do
        scenario "is not found" do
          @uri = "/devices/#{@not_owned_device.id.as_json}"
          visit @uri
          should_have_a_not_found_resource(@uri)
        end
      end

      context "with illegal id" do
        scenario "is not found" do
          @uri = "/devices/0"
          visit @uri
          save_and_open_page
          should_have_a_not_found_resource(@uri)
        end
      end
    end

  end
end
