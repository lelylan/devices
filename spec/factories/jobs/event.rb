FactoryGirl.define do
  factory :event do
    resource_owner_id { FactoryGirl.create(:user).id }
    resource_id { FactoryGirl.create(:device).id }
    #resource_uri { a_uri(FactoryGirl.create(:device)) }
    resource 'status'
    event 'update'
    source 'lelylan'
    data { JSON.parse('{"json": "ok"}') }
  end
end
