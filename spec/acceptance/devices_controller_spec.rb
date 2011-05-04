require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "DevicesController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }

  context ".index" do
    context "when not logged in" do
      scenario "is not authorized" do
        visit "/devices.json"
        page.status_code.should == 401
        page.should have_content SETTINGS[:messages][:access_denied]
      end
    end

    context "when logged in" do
      before { login(@user) } 
      let(:device) { Factory(:device) }
      let(:not_owned_device) { Factory(:not_owned_device) }

      scenario "view all resources" do
        visit "/devices.json"
        page.status_code.should == 200
        save_and_open_page  
      end
    end

  end
end
