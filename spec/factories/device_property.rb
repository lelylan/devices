FactoryGirl.define do
  factory :device_property, aliases: %w(device_status) do
    property_id Settings.resource_id
    value       'off'
  end

  factory :device_intensity, parent: :device_property do
    property_id Settings.another_resource_id
    value       '0'
  end
end
