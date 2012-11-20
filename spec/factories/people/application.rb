FactoryGirl.define do
  factory :application, class: Doorkeeper::Application do
    sequence(:name){ |n| "Application #{n}" }
    redirect_uri 'http://app.dev/callback'
    resource_owner_id { User.new.id }
  end
end
