require 'spec_helper'

describe Type do

  let(:user)     { FactoryGirl.create :user }
  let(:resource) { FactoryGirl.create :type, resource_owner_id: user.id }

  it 'connects to type database' do
    Type.database_name.should == 'types_test'
  end

  it 'creates a device' do
    resource.id.should_not be_nil
  end

  it 'connects the properties' do
    resource.property_ids.should have(2).items
  end

  it 'belongs to the user' do
    resource.resource_owner_id.should == user.id
  end
end
