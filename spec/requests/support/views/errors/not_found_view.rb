module ViewNotFoundMethods

  # Accepted values as type are 'resource' and 'connection'
  def should_have_not_found_resource(uri, type='resource')
    error_code = 'notifications.' + type + '.not_found'
    json = JSON.parse(page.source)
    json = Hashie::Mash.new json

    json.status.should == '404'
    json.request.should match Regexp.escape(uri)
    json.error.code.should == error_code
    json.error.description.should include 'not found'
  end

end

RSpec.configuration.include ViewNotFoundMethods
