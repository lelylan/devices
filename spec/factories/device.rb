FactoryGirl.define do
  factory :device do
    resource_owner_id { FactoryGirl.create(:user).id }
    type { a_uri FactoryGirl.create(:type) }
    name 'Closet dimmer'
    physical { FactoryGirl.build(:device_physical) }
  end

  trait :with_no_physical do
    after(:create) do |device|
      device.update_attributes(physical: nil)
    end
  end

  trait :with_device_properties do
    properties {[
      FactoryGirl.build(:device_status),
      FactoryGirl.build(:device_intensity) ]}
  end
end
