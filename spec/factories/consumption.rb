Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :consumption do
<<<<<<< HEAD
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
=======
    uri Settings.consumptions.instantaneous.uri
    device_uri Settings.device.uri
    created_from Settings.user.uri
    value 1.25
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
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
  end
end

