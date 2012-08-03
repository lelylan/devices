FactoryGirl.define do
  factory :device_physical do
    uri "https://ws.lelylan.com/physicals/#{Settings.resource_id}"
  end
end
