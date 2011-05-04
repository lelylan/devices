SETTINGS = HashWithIndifferentAccess.new(
  YAML.load_file("#{Rails.root}/spec/support/settings.yml")
)

FactoryGirl.define do
  factory :user do
     email "alice@example.com"
     password "example"
     uri SETTINGS[:uri]
  end
end

