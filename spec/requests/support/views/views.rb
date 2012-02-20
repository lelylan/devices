module ViewMethods
  # Device resource representation
  def should_have_device(device)
    page.should have_content device.id.as_json
    page.should have_content device.uri
    page.should have_content device.name
    page.should have_content device.type_uri
  end

  # Device resource not represented
  def should_not_have_device(device)
    page.should_not have_content device.created_from
  end

  # Device resource connections
  def should_have_device_connections(device)
    should_have_device_properties(device.device_properties)
    should_have_device_physicals(device.device_physicals)
  end

  # Device properties representation
  def should_have_device_properties(properties)
    properties.each do |property|
      page.should have_content property.uri
      page.should have_content property.name
      page.should have_content property.value
    end
  end

  # Device physical connection
  def should_have_device_physicals(physicals)
    physicals.each do |physical|
      page.should have_content physical.uri
    end
  end



  # History resource representation
  def should_have_history(history)
    page.should have_content history.uri
    page.should have_content history.device_uri
  end

  # History property resource representation
  def should_have_history_property(property)
    page.should have_content property.uri
    page.should have_content property.value
  end

  # Consumption resource representation
  def should_have_consumption(consumption)
    page.should have_content consumption.uri
    page.should have_content consumption.created_from
    page.should have_content consumption.device_uri
    page.should have_content consumption.type
    page.should have_content consumption.value.to_s
    page.should have_content consumption.unit
    page.should have_content consumption.occur_at.to_s
    if consumption.type
      page.should have_content consumption.end_at.to_s
      page.should have_content consumption.duration.to_s
    end
  end

  # Consumption resource not represented
  def should_not_have_consumption(consumption)
    page.should_not have_content consumption.created_from
  end

  # Unite node resource representation
  def should_have_unite_node(unite_node)
    page.should have_content unite_node.uri
    page.should have_content unite_node.created_from
    page.should have_content unite_node.name
    page.should have_content unite_node.token
    page.should have_content "?uri=#{unite_node.uri}"
  end

  # Unite node resource not represented
  def should_not_have_unite_node(unite_node)
    page.should_not have_content unite_node.uri
  end
end

RSpec.configuration.include ViewMethods
