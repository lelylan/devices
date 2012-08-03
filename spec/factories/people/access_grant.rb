FactoryGirl.define do
  factory :access_grant, class: Doorkeeper::AccessGrant do
    resource_owner_id Moped::BSON::ObjectId('000aa0a0a000a00000000000')
    application
    redirect_uri 'https://app.com/callback'
    expires_in 100
    scopes 'public write'
  end
end
