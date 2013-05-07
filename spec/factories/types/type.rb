FactoryGirl.define do
  factory :type, traits: %w(with_properties) do
    name 'Dimmer'
    categories ['lights']
  end

  trait :with_properties do
    before(:create) do |resource|
      status = FactoryGirl.create :status
      intensity = FactoryGirl.create :intensity
      resource.update_attributes property_ids: [status.id, intensity.id]
    end
  end

  factory :type_with_no_properties do
    name 'Dimmer'
  end
end
