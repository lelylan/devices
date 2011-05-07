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

  # Device properties representation
  def should_have_device_properties(properties)
    properties.each do |property|
      page.should have_content property.uri
      page.should have_content property.name
      page.should have_content property.value
    end
  end

  # Device functions representation
  def should_have_device_functions(functions)
    functions.each do |function|
      page.should have_content function.uri
      page.should have_content function.name
    end
  end

  # Resource not found
  def should_have_a_not_found_resource(uri)
    page.status_code.should == 404
    page.should have_content "404"
    page.should have_content uri
    page.should have_content "notifications.document.not_found"
    page.should have_content "not found"
  end

  # Resource not valid
  def should_have_a_not_valid_resource
    page.status_code.should == 422
  end

  # Pending resource representation
  def should_have_pending(pending)
    page.status_code.should == 200
    page.should have_content pending.uri
    page.should have_content pending.device_uri
    page.should have_content pending.function_uri
    page.should have_content pending.function_name
    page.should have_content "true"
  end

  # Pending property representation (connected to pending resource)
  def should_have_pending_property(property)
    page.should have_content property.uri
    page.should have_content property.old_value
    page.should have_content property.value
  end
end

RSpec.configuration.include ViewMethods, :type => :acceptance

