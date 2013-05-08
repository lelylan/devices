FactoryGirl.define do
  factory :user do
    full_name 'Alice Wonderland'
    email 'alice@example.com'
    username 'alice'
    rate_limit 5000
  end
end
