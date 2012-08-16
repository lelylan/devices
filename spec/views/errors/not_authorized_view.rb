module ViewNotAuthorizedMethods

  def has_unauthorized_resource
    json = JSON.parse(page.source)
    json = Hashie::Mash.new json

    json.status.should     == '401'
    json.request.should    == page.current_url

    json.error.code.should        == 'notifications.access.not_authorized'
    json.error.description.should == 'Token not valid'
  end

end

RSpec.configuration.include ViewNotAuthorizedMethods
