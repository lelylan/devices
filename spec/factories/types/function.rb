FactoryGirl.define do
  factory :function, aliases: %w(set_intensity) do
    resource_owner_id Settings.resource_owner_id
    name 'Set intensity'
  end

  factory :turn_on, parent: :function do
    resource_owner_id Settings.resource_owner_id
    name 'Turn on'
  end
end
