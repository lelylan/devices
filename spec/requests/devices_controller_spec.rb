require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "DevicesController" do
  before { Device.destroy_all }


  # GET /devices
  context ".index" do
    before { @uri = "/devices" }
    before { @resource = Factory(:device) }
    before { @resource_not_owned = Factory(:device_not_owned) }

    it_should_behave_like "protected resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth }

      scenario "view all resources" do
        visit @uri
        save_and_open_page
        page.status_code.should == 200
        should_have_device(@resource)
        should_not_have_device(@resource_not_owned)
        #should_have_pagination(@uri)
        should_have_valid_json(page.source)
        #should_have_root_as('resources')
      end
    end
  end
end
