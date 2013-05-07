FactoryGirl.define do
  factory :status_for_function, class: FunctionProperty do
    id { FactoryGirl.create(:status).id }
    value 'on'
  end

  factory :intensity_for_function, class: FunctionProperty do
    id { FactoryGirl.create(:intensity).id }
    value '0'
  end
end
