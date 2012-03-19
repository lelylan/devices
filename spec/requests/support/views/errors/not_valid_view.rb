module ViewNotValidMethods

  # Resource not valid
  def should_have_a_not_valid_resource(code='notifications.resource.not_valid', error='uri is not a valid')
    json = JSON.parse(page.source)
    json = Hashie::Mash.new json
    json.status.should == '422'
    json['method'].should == 'POST'
    json.request.should match @uri
    json.error.code.should == code
    json.error.description.should include error
  end

end

RSpec.configuration.include ViewNotValidMethods
