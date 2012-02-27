module HelperMethods
  # Basic authentication.
  def basic_auth
    body = { username: Settings.user.email, password: Settings.user.password }
    stub_http_request(:post, Settings.user.auth).with(body: body).to_return(body: fixture('user.json'))
    page.driver.browser.authorize(Settings.user.email, Settings.user.password)
  end

  # Basic authentication cleanup. This is necessary because
  # sequenced requests keep the basic authentication valid.
  def basic_auth_cleanup
    body = { username: '', password: '' }
    stub_http_request(:post, Settings.user.auth).with(body: body).to_return(status: 401)
    page.driver.browser.authorize('', '')
  end

  # Valid JSON.
  def should_have_valid_json
    expect { JSON.parse(page.source) }.to_not raise_error
  end
end

RSpec.configuration.include HelperMethods
