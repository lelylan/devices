FactoryGirl.define do
  factory :property, aliases: %w(status) do
    resource_owner_id Settings.resource_id
    name    'Status'
    default 'off'
    values  ['on', 'off']
  end

  factory :intensity, parent: :property do
    resource_owner_id Settings.resource_id
    name    'Intensity'
    default '0'
    values  ['0', '50', '100']
  end
end
