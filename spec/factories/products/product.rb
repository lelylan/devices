FactoryGirl.define do
  factory :product do
    secret 'd4ee462185f0d11ccadc2632ece812087eeed39d71d9109f982a38af646e69c0'
    articles {[ FactoryGirl.build(:article) ]}
  end
end
