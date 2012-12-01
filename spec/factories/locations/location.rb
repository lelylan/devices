Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :location, aliases: ['house', 'root'] do
    name 'House'
    resource_owner_id '0000aaa0a000a00000000000'
  end

  trait :with_devices do
    after(:create) do |location|
      device = FactoryGirl.create :device, resource_owner_id: location.resource_owner_id
      location.update_attributes device_ids: [device.id]
    end
  end
end
