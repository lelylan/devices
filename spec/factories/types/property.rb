FactoryGirl.define do
  factory :property, aliases: %w(status) do
    resource_owner_id Settings.resource_id
    name       'Status'
    default    'off'
    suggested  {{ 'on' => 'On', 'off' => 'Off' }}
  end

  factory :intensity, parent: :property do
    resource_owner_id Settings.resource_id
    name      'Intensity'
    default   '0'
    suggested { { '0' => 'min', '50' => 'half', '100' => 'max' } }
  end
end
