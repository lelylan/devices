Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do

  # Device with no connections
  factory :device do
    uri Settings.device.uri
    created_from Settings.user.uri
    name Settings.device.name
    type_uri Settings.type.uri
    type_name Settings.type.name
  end

  # Not owned device with no connections
  factory :not_owned_device, parent: :device do
    created_from Settings.another_user.uri
  end

  # Device with all connections
  # (statuses are not present because retrived from the type every time)
  factory :device_complete, parent: :device do
    device_categories {[ Factory.build(:device_category) ]}
    device_properties {[
      Factory.build(:device_status),
      Factory.build(:device_intensity) ]}
    device_functions {[
      Factory.build(:device_set_intensity),
      Factory.build(:device_turn_on),
      Factory.build(:device_turn_off) ]}
    device_physicals { [ Factory.build(:device_physical) ] }
  end

  # Device connected to a type which has range definitions
  factory :device_range_complete, parent: :device_complete do
    type_uri Settings.type_range.uri
    type_name Settings.type_range.name
  end

  # Device with no physical connection (it has all other connections)
  factory :device_no_physical, parent: :device_complete do |d|
    d.device_physicals {}
  end

  # -----------------
  # Connections
  # -----------------

  factory :device_category, class: :device_category do
    name Settings.category.name
    uri Settings.category.uri
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
