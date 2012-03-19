module ViewNotValidMethods

  # Resource not valid
  def should_have_a_not_valid_resource(options = {})
    options = default.merge(options)
    json = JSON.parse(page.source)
    json = Hashie::Mash.new json

    json.request.should match @uri
    json.status.should == '422'
    json[:method].should == options[:method]
    json.error.code.should == options[:code]
    json.error.description.should include options[:error]
  end

  def default
    {
      method: 'POST',
      code: 'notifications.resource.not_valid',
      error: 'uri is not a valid',
    }
  end
end

RSpec.configuration.include ViewNotValidMethods
