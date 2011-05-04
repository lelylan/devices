module HelperMethods
  def login(user)
    page.driver.basic_authorize(user.email, "example")
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
