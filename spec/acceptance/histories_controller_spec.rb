require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "HisotriesController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { History.destroy_all }

  # GET /devices/{device-id}/histories
  context ".index" do
    before { @resource = Factory(:device_complete) }
    before { @history = Factory(:history_complete) }
    before { @not_owned = Factory(:not_owned_history) }
    before { @base_history = Factory(:history) }
    before { @uri = "#{host}/devices/#{@resource.id}/histories" }

    it_should_behave_like "protected resource", "visit(@uri)"

    context "when logged in" do
      before { basic_auth(@user) } 
      before { visit @uri }
     
      scenario "view device history resources" do
        page.status_code.should == 200
        should_have_history @history
        should_have_history @base_history
        should_have_valid_json(page.body)
        should_have_root_as('histories')
      end

      scenario "view history properties" do
        @history.history_properties.each do |property|
          should_have_history_property property
        end
      end
      
      scenario "do not view not related hisotries" do
        page.should_not have_content @not_owned.device_uri
      end 
    end
  end
end
