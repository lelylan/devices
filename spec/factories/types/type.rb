FactoryGirl.define do
  factory :type do
  end

  trait :with_properties do
    before(:create) do |resource|
      status = FactoryGirl.create :status
      intensity = FactoryGirl.create :intensity
      resource.update_attributes(properties: [status.id, intensity.id])
    end
  end
end
