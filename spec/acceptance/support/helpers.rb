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

  # Valid JSON
  def should_have_valid_json(body)
    lambda {JSON.parse(body)}.should_not raise_error
  end

  def should_have_root_as(resource_name)
    page.should have_content('"' + resource_name + '"')
  end

  def should_have_pagination_uri(type, options)
    resource = options.delete(:resource) 
    uri = "\"#{type}\": \"http://www.example.com/#{resource}?page=#{options[:page]}&per=#{options[:per]}"
    page.should have_content uri
  end

  # Simply check the ezistence
  def should_have_test_pagination(resource)
    should_have_pagination_uri('first', page: 1, per: 100, resource: resource)
    should_have_pagination_uri('previous', page: 1, per: 100, resource: resource)
    should_have_pagination_uri('next', page: 1, per: 100, resource: resource)
    should_have_pagination_uri('last', page: 1, per: 100, resource: resource)
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
