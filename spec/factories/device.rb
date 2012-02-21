Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do

  # Device
  factory :device do
    uri Settings.device.uri
    name 'Closet dimmer'
    created_from Settings.user.uri
    type_uri Settings.type.uri
    device_properties {[
      Factory.build(:device_status),
      Factory.build(:device_intensity) ]}
    device_physicals {[ Factory.build(:device_physical) ]}
  end

  # Device with no connections
  factory :device_no_connections, parent: :device do
    device_properties []
    device_physicals []
  end

  # Device with no physical connection
  factory :device_no_physical, parent: :device do
    device_physicals []
  end

  # Device not owned
  factory :device_not_owned, parent: :device do
    created_from Settings.user.another.uri
  end


  # --------------
  # Connections
  # --------------

  factory :device_status, class: :device_property do
    uri Settings.properties.status.uri
    value 'off'
  end

  factory :device_intensity, class: :device_property do
    uri Settings.properties.intensity.uri
    value '0.0'
  end
  
  factory :device_physical do
    uri Settings.physical.uri
  end
end
