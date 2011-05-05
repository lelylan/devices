module HelperMethods
  # Basic authentication definition
  def basic_auth(user)
    page.driver.basic_authorize(user.email, "example")
  end

  # Basic authentication cleanup
  def basic_auth_cleanup
    page.driver.basic_authorize("", "")
  end

  # Not authorized behavior
  def should_not_be_authorized
    page.status_code.should == 401
    page.should have_content Settings.messages.access_denied
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
