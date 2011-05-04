require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "DevicesController" do
  before { @user = Factory(:user) }

  context ".index" do
    context "when not logged in" do
      scenario "is not authorized" do
        visit "Devices"
        current_url.should == host + "/login"
      end
    end

    context "when logged in" do
      before { login(@user) } 
      scenario "view all resources" do
        visit "/devices"
        save_and_open_page
      end
    end

  end
end
