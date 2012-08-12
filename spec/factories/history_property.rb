FactoryGirl.define do
  factory :history_property, aliases: %w(history_status) do
    value 'off'
    uri   { "https://api.lelylan.com/properties/#{FactoryGirl.create(:property).id}" }
  end

  factory :history_intensity, parent: :history_property do
    value '0'
    uri   { "https://api.lelylan.com/properties/#{FactoryGirl.create(:property).id}" }
  end
end
