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

  # Check correct generation single URI on pagination
  def should_have_pagination_uri(type, options)
    options = options.dup
    path = options.delete(:path) 
    uri = "\"#{type}\": \"#{host}#{path}?page=#{options[:page]}&per=#{options[:per]}"
    uri += "&type=#{options[:type]}" if options[:type]
    page.should have_content uri
  end

  # Check the existence of pagination on index views
  def should_have_pagination(resource)
    params = { page: Settings.pagination.page, per: Settings.pagination.per, resource: resource}
    should_have_pagination_uri('first', params)
    should_have_pagination_uri('previous', params)
    should_have_pagination_uri('next', params)
    should_have_pagination_uri('last', params)
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
