Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirlGirl.define do
  factory :history do
    device_uri Settings.device.uri
    created_from Settings.user.uri
    history_properties {[
      FactoryGirl.build(:history_property_intensity),
      FactoryGirl.build(:history_property_status)
    ]}
  end

  factory :history_no_connections, parent: :history do
    history_properties []
  end

  factory :history_not_owned, parent: :history do
    created_from Settings.user.another.uri
  end

  factory :history_not_owned_device, parent: :history do
    device_uri Settings.device.another.uri
  end

  # -------------
  # Connections
  # -------------

  factory :history_property_status, class: :history_property do
    uri Settings.properties.status.uri
    value 'on'
  end

  factory :history_property_intensity, class: :history_property do
    uri Settings.properties.intensity.uri
    value '100.0'
  end

end
