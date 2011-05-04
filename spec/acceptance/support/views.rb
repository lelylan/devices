module ViewMethods
  # Device resource representation
  def should_have_device(device)
    page.should have_content device.id.as_json
    page.should have_content device.uri
    page.should have_content device.name
    page.should have_content device.created_from
    page.should have_content device.type_uri
    page.should have_content device.type_name
  end

  # Device resource not represented
  def should_not_have_device(device)
    page.should_not have_content device.created_from
  end

  # Resource not found
  def should_have_a_not_found_resource(uri)
    page.status_code.should == 404
    page.should have_content "404"
    page.should have_content uri
    page.should have_content "notifications.document.not_found"
    page.should have_content "not found"
  end
end

RSpec.configuration.include ViewMethods, :type => :acceptance

