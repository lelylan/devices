require 'spec_helper'

describe Product do

  let(:product) { FactoryGirl.create :product }

  it 'connects to products database' do
    Product.database_name.should == 'products_test'
  end

  it 'creates a products' do
    product.id.should_not be_nil
  end

  it 'creates an embedded article' do
    product.articles.first.should_not be_nil
  end
end
