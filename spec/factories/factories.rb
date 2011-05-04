SETTINGS = HashWithIndifferentAccess.new(
  YAML.load(ERB.new(File.new("#{Rails.root}/spec/support/settings.yml")).result)
)

FactoryGirl.define do
  factory :user do
    uri SETTINGS[:user][:uri]
    email "alice@example.com"
    password "example"
  end

  factory :device do
    puts "::::::" + SETTINGS[:user][:uri].inspect
    uri SETTINGS[:device][:uri]
    created_from SETTINGS[:user][:uri]
    name "Dimmer"
    type_uri SETTINGS[:type][:uri]
    type_name SETTINGS[:type][:name]
  end

  factory :not_owned_device, parent: :device do
    created_from SETTINGS[:another_user][:uri]
  end
end

