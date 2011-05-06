Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :user do
    uri Settings.user.uri
    email Settings.user.email
    password "example"
  end

  # BASIC DEVICE
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
    property_uri Settings.properties.status.uri
    value Settings.properties.status.default_value
  end

  factory :device_intensity, class: :device_property do
    name Settings.properties.intensity.name
    property_uri Settings.properties.intensity.uri
    value Settings.properties.intensity.default_value
  end

  factory :device_set_intensity, class: :device_function do
    name Settings.functions.set_intensity.name
    function_uri Settings.functions.set_intensity.function_uri
  end

  factory :device_turn_on, class: :device_function do
    name Settings.functions.turn_on.name
    function_uri Settings.functions.turn_on.function_uri
  end

  factory :device_turn_off, class: :device_function do
    name Settings.functions.turn_off.name
    function_uri Settings.functions.turn_off.function_uri
  end

  factory :device_physical do
    physical_id Settings.unite_node.physical_id
    unite_node_uri Settings.unite_node.uri
  end
end

