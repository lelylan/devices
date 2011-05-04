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
      scenario "view all resources" do
        visit "/devices.json"
        page.status_code.should == 200

      end
    end

  end
end
