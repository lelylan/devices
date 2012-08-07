FactoryGirl.define do
  factory :history do
    resource_owner_id Settings.resource_id
    device "https://api.lelylan.com/devices/#{Settings.resource_id}"
    properties {[
      FactoryGirl.build(:history_status),
      FactoryGirl.build(:history_intensity)
    ]}
  end
end
