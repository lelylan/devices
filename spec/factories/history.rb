Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :history do
<<<<<<< HEAD
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

=======
    uri Settings.history.uri
    device_uri Settings.device.uri
  end

  factory :history_complete, parent: :history do |p|
    p.history_properties {[
      Factory.build(:history_property_intensity),
      Factory.build(:history_property_status)
    ]}
  end
  
  factory :not_owned_history, parent: :history_complete do |p|
    device_uri Settings.another_device.uri
  end

  factory :history_property_intensity, class: :history_property do
    uri Settings.properties.intensity.uri
    value Settings.properties.intensity.new_value
  end

  factory :history_property_status, class: :history_property do
    uri Settings.properties.status.uri
    value Settings.properties.status.new_value
  end
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
end
