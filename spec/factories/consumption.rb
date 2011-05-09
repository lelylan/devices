Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :consumption do
    uri Settings.consumptions.instantaneous.uri
    device_uri Settings.device.uri
    created_from Settings.user.uri
    consumption 1.25
    occur_at Time.now
  end

  factory :another_consumption, parent: :consumption do
    device_uri Settings.another_device.uri
  end

  factory :durational_consumption, parent: :consumption do
    uri Settings.consumptions.durational.uri
    type 'durational'
    duration 60
    occur_at Time.now
    end_at Time.now + 60
  end

  factory :another_durational_consumption, parent: :durational_consumption do
    device_uri Settings.another_device.uri
  end

  factory :not_owned_consumption, parent: :consumption do
    created_from Settings.another_user.uri
  end
end

