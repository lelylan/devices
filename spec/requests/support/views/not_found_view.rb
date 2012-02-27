module ViewNotFoundMethods

  # Accepted values as type are 'resource' and 'connection'
  def should_have_not_found_resource(uri, type='resource')
    error_code = 'notifications.' + type + '.not_found'
    json = JSON.parse(page.source)
    json = Hashie::Mash.new json

    json.status.should == '404'
    json.request.should match uri
    json.error.code.should == error_code
    json.error.description.should include 'not found'
  end


  # Resource not valid
  def should_have_a_not_valid_resource
    page.status_code.should == 422
  end
end

RSpec.configuration.include ViewNotFoundMethods
