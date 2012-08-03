module ViewNotValidMethods

  # Resource not valid
  def has_a_not_valid_resource(options = {})
    options = not_valid_default.merge(options)
    json    = JSON.parse(page.source)
    json    = Hashie::Mash.new json

    json.request.should match Regexp.escape(uri)
    json.status.should     == '422'
    json[:method].should   == options[:method]
    json.error.code.should == options[:code]
    page.should have_content  options[:error]
  end

  def not_valid_default
    { method: 'POST',
      code: 'notifications.resource.not_valid',
      error: 'uri is not a valid' }
  end
end

RSpec.configuration.include ViewNotValidMethods
