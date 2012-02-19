Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :history do
    uri Settings.history.uri
    device_uri Settings.device.uri
    history_properties {[
      Factory.build(:history_property_intensity),
      Factory.build(:history_property_status)
    ]}
  end

  factory :history_no_connections, parent: :history do
    history_properties []
  end

  factory :history_not_owned, parent: :history do
    device_uri Settings.device.uri + 'not-owned'
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
