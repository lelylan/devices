require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "PendingsController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { Pending.destroy_all }

  # GET /devices/{device-id}/pendings
  context ".index" do
    before { @resource  = Factory(:device_complete) }
    before { @pending   = Factory(:pending_complete) }
    before { @not_owned = Factory(:not_owned_pending) }
    before { @closed    = Factory(:closed_pending) }
    before { @uri = "/devices/#{@resource.id}/pendings" }

    it_should_behave_like "protected resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth(@user) }
      before {  visit @uri }

      scenario "view device pending resources" do
        page.status_code.should == 200
        should_have_pending(@pending)
        should_have_pagination("devices/#{@resource.id}/pendings")
        should_have_valid_json(page.body)
        should_have_root_as('resources')
      end

      scenario "view pending properties" do
        @pending.pending_properties.each do |property|
          should_have_pending_property(property)
        end
      end
      
      scenario "do not view not related pendings" do
        page.should_not have_content @not_owned.device_uri
      end

      scenario "do not see closed pendings" do
        page.should_not have_content @closed.uri
      end
    end
  end
end
