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
    before { @uri = "#{host}/devices/#{@resource.id}/pendings" }

    it_should_behave_like "protected resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      scenario "view device pending resources" do
        visit @uri
        page.status_code.should == 200
        should_have_pending(@pending)
        @pending.pending_properties.each do |property|
          should_have_pending_property(property)
        end
        page.should_not have_content @not_owned.device_uri
        should_have_valid_json(page.body)
      end
    end
  end
end
