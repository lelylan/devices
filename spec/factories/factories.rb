Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :user do
    uri Settings.user.uri
    email Settings.user.email
    password "example"
  end



  # PENDING BASE
  factory :pending do
    uri Settings.pending.uri
    device_uri Settings.device.uri
    function_uri Settings.functions.set_intensity.uri
    function_name Settings.functions.set_intensity.name
  end

  # Pending complete with properties
  factory :pending_complete, parent: :pending do |p|
    p.pending_properties {[
      Factory.build(:pending_property_intensity),
      Factory.build(:pending_property_status)
    ]}
  end
  
  # Pending resource close
  factory :closed_pending, parent: :pending_complete do |p|
    uri Settings.pending_closed.uri
    pending_status false
  end

  # Pending of a different device
  factory :not_owned_pending, parent: :pending_complete do |p|
    device_uri Settings.another_device.uri
  end

  factory :pending_property_intensity, class: :pending_property do
    uri Settings.properties.intensity.uri
    value "10.0"
    old_value "0.0"
  end

  factory :pending_property_status, class: :pending_property do
    uri Settings.properties.status.uri
    value "off"
    old_value "on"
  end



  # DEVICE BASE
  factory :device do
    uri Settings.device.uri
    created_from Settings.user.uri
    name Settings.device.name
    type_uri Settings.type.uri
    type_name Settings.type.name
  end

  # NOT OWNED DEVICE
  factory :not_owned_device, parent: :device do
    created_from Settings.another_user.uri
  end

  # COMPLETE DEVICE WITH PROPERTIES, FUNCTIONS AND PHYSICAL
  factory :device_complete, parent: :device do |d|
    d.device_properties {[
      Factory.build(:device_status),
      Factory.build(:device_intensity)
    ]}
    d.device_functions {[
      Factory.build(:device_set_intensity),
      Factory.build(:device_turn_on),
      Factory.build(:device_turn_off),
    ]}
    d.device_physicals { [ Factory.build(:device_physical) ] }
  end

  # DEVICE WITH NO PHYSICAL. PROPERTIES AND FUNCTIONS ARE PRESENT
  factory :device_no_physical, parent: :device_complete do |d|
    d.device_physicals { }
  end

  factory :device_status, class: :device_property do
    name Settings.properties.status.name
    uri Settings.properties.status.uri
    value Settings.properties.status.default_value
  end

  factory :device_intensity, class: :device_property do
    name Settings.properties.intensity.name
    uri Settings.properties.intensity.uri
    value Settings.properties.intensity.default_value
  end

  factory :device_set_intensity, class: :device_function do
    name Settings.functions.set_intensity.name
    uri Settings.functions.set_intensity.uri
  end

  factory :device_turn_on, class: :device_function do
    name Settings.functions.turn_on.name
    uri Settings.functions.turn_on.uri
  end

  factory :device_turn_off, class: :device_function do
    name Settings.functions.turn_off.name
    uri Settings.functions.turn_off.uri
  end

  factory :device_physical do
    physical_id Settings.unite_node.physical_id
    unite_node_uri Settings.unite_node.uri
  end
end

