FactoryGirl.define do
  factory :device_property, aliases: %w(device_status) do
    property_id { FactoryGirl.create(:property).id }
    value 'off'
    physical_value 'off'
  end

  factory :device_intensity, parent: :device_property do
    property_id { FactoryGirl.create(:property).id }
    value '0'
    physical_value '0'
  end
end
