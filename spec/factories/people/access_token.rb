FactoryGirl.define do
  factory :access_token, class: Doorkeeper::AccessToken do
    resource_owner_id Moped::BSON::ObjectId('000aa0a0a000a00000000000')
    application
    expires_in 2.hours
  end
end
