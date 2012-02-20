module HelperMethods

  # Basic authentication.
  def basic_auth
    body = { username: Settings.user.email, password: Settings.user.password }
    stub_http_request(:post, Settings.user.auth).with(body: body).to_return(body: fixture('user.json'))
    page.driver.browser.authorize(Settings.user.email, Settings.user.password)
  end

  # Basic authentication cleanup. This is necessary otherwise several 
  # requests keep the basic authentication valid.
  def basic_auth_cleanup
    body = { username: '', password: '' }
    stub_http_request(:post, Settings.user.auth).with(body: body).to_return(status: 401)
    page.driver.browser.authorize('', '')
  end

  # Not authorized behavior
  def should_not_be_authorized
    page.status_code.should == 401
    page.should have_content '"access.denied"'
    page.should have_content 'Access denied'
  end

  # Valid JSON
  def should_have_valid_json(body)
    expect { JSON.parse(body) }.to_not raise_error
  end

  # Root key for a list of resources
  def should_have_root_as(resource_name)
    page.should have_content('"' + resource_name + '"')
  end
end

RSpec.configuration.include HelperMethods
