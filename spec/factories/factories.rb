SETTINGS = HashWithIndifferentAccess.new(
  YAML.load_file("#{Rails.root}/spec/support/settings.yml")
)

FactoryGirl.define do
  factory :user do
    uri SETTINGS[:user][:uri]
    email "alice@example.com"
    password "example"
  end

  factory :device do
    uri SETTINGS[:device][:uri]
    created_from SETTINGS[:user][:uri]
    name "Dimmer"
    type_uri SETTINGS[:type][:uri]
    type_name SETTINGS[:type][:name]
  end
end

