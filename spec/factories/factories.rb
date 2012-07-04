Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :user do
    uri Settings.user.uri
    email Settings.user.email
    password "example"
  end
end
