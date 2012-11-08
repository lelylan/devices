FactoryGirl.define do
  factory :event do
    resource_owner_id { FactoryGirl.create(:user).id }
    resource_id { FactoryGirl.create(:device).id }
    resource 'status'
    event 'update'
    data { JSON.parse('{"json": "ok"}') }
  end
end
