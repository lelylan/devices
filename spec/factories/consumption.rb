FactoryGirl.define do
  factory :consumption do
    resource_owner_id Settings.resource_owner_id
    device    "https://api.lelylan.com/devices/#{Settings.device_id.to_s}"
    value     125
    occur_at  Time.now
  end

  trait :durational do
    type    'durational'
    duration 60
    occur_at Time.now
    end_at   Time.now + 60
  end
end

