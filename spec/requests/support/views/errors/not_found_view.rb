module ViewNotFoundMethods

  # Accepted values as type are 'resource' and 'connection'
  def should_have_not_found_resource(options={})
    options = not_found_default.merge(options)
    json = JSON.parse(page.source)
    json = Hashie::Mash.new json

    json.status.should == '404'
    json.error.code.should == options[:code]
    json.error.uri match Regexp.escape(options[:uri])
  end

  def not_found_default
    {
      method: 'GET',
      code: 'notifications.resource.not_found',
    }
  end
end

RSpec.configuration.include ViewNotFoundMethods
