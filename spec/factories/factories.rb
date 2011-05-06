Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :user do
    uri Settings.user.uri
    email Settings.user.email
    password "example"
  end

  factory :device do
    uri Settings.device.uri
    created_from Settings.user.uri
    name Settings.device.name
    type_uri Settings.type.uri
    type_name Settings.type.name
  end

  factory :not_owned_device, parent: :device do
    created_from Settings.another_user.uri
  end

  factory :device_complete, parent: :device do |d|
    d.device_functions {[
      Factory.build(:device_status),
      Factory.build(:device_intensity)
    ]}
    d.device_physicals { [ Factory.build(:device_physical) ] }
  end

  factory :device_status, class: :device_property do
    name Settings.properties.status.name
    property_uri Settings.properties.status.uri
    value Settings.properties.status.value
  end

  factory :device_intensity, class: :device_property do
    name Settings.properties.intensity.name
    property_uri Settings.properties.intensity.uri
    value Settings.properties.intensity.value
  end


  factory :device_physical do
    physical_id Settings.unite_node.physical_id
    unite_node_uri Settings.unite_node.uri
  end
end

