Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :consumption do
    device_uri Settings.device.uri
    created_from Settings.user.uri
    value 125.00
    occur_at Time.now
  end

  factory :consumption_durational, parent: :consumption do
    type 'durational'
    duration 60
    occur_at Time.now - 60
    end_at Time.now
  end

  factory :consumption_not_owned, parent: :consumption do
    created_from Settings.user.another.uri
  end
end

