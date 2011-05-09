Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :history do
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
end
