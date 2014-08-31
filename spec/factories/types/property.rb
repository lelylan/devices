FactoryGirl.define do

  factory :property, aliases: %w(status) do
    resource_owner_id Settings.resource_id
    name     'Status'
    default  'off'
    accepted { [ { 'key' => 'on', 'value' => 'On' }, { 'key'=> 'off', 'value' => 'Off' } ] }
  end

  factory :intensity, parent: :property do
    resource_owner_id Settings.resource_id
    name     'Intensity'
    default  '0'
    accepted { [ { 'key' => '0', 'value' => 'min' }, { 'key'=> '50', 'value' => 'half' }, { 'key'=> '100', 'value' => 'max' } ] }
  end
end
