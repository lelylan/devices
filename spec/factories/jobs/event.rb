FactoryGirl.define do
  factory :event do
    resource 'status'
    event 'update'
    data { JSON.parse('{"json": "ok"}') }
  end
end
