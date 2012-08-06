FactoryGirl.define do
  factory :status_for_function, class: FunctionProperty do
    uri 'https://api.lelylan.com/properties/status'
    value 'on'
  end

  factory :intensity_for_function, class: FunctionProperty do
    uri 'https://api.lelylan.com/properties/intensity'
    value '0'
  end
end
