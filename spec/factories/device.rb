FactoryGirl.define do
  factory :device do
    resource_owner_id Settings.resource_id
    type { a_uri FactoryGirl.create(:type) }
    name 'Closet dimmer'
    properties {[
      FactoryGirl.build(:device_status),
      FactoryGirl.build(:device_intensity) ]}
    physical { FactoryGirl.build(:device_physical) }
  end

  trait :with_no_physical do
    physical = nil
  end
end
