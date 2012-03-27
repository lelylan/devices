module ViewNotAuthorizedMethods

  # Accepted values as type are 'resource' and 'connection'
  def should_have_not_authorized_resource(uri)
    json = JSON.parse(page.source)
    json = Hashie::Mash.new json

    json.status.should == '401'
    json.request.should match Regexp.escape(uri)
    json.error.code.should == 'notifications.access.denied'
    json.error.description.should include 'Access denied'
  end

end

RSpec.configuration.include ViewNotAuthorizedMethods
