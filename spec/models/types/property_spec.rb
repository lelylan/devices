require 'spec_helper'

describe Property do

  let(:user)     { FactoryGirl.create :user }
  let(:resource) { FactoryGirl.create :property, resource_owner_id: user.id }

  it 'connects to type database' do
    Property.database_name.should == 'types_test'
  end

  it 'creates a device' do
    resource.id.should_not be_nil
  end

  it 'belongs to the user' do
    resource.resource_owner_id.should == user.id
  end
end
