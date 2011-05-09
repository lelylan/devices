Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :user do
    uri Settings.user.uri
    email Settings.user.email
    password "example"
  end

  factory :consumption do
    uri Settings.consumptions.instantaneous.uri
    created_from Settings.user.uri
    consumption 1.25
    occur_at Time.now
  end

  factory :durational_consumption, parent: :consumption do
    uri Settings.consumptions.durational.uri
    type 'durational'
    duration 60
    occur_at Time.now
    end_at Time.now + 60
  end
end

