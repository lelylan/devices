FactoryGirl.define do
  factory :device do
    resource_owner_id { FactoryGirl.create(:user).id }
    type { { id: FactoryGirl.create(:type).id } }
    name 'Closet dimmer'
    physical { { 'uri' => "http://arduino.casa.com/#{id}" } }
  end

  trait :with_no_physical do
    physical nil
  end

  trait :with_device_properties do
    properties {[
      FactoryGirl.build(:device_status),
      FactoryGirl.build(:device_intensity) ]}
  end
end
