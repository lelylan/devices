require 'spec_helper'

describe Function do

  let(:user)       { FactoryGirl.create :user }
  let(:status)     { FactoryGirl.create :status }
  let(:intensity)  { FactoryGirl.create :intensity }
  let(:properties) { [ { uri: a_uri(status), value: 'on' }, { uri: a_uri(intensity) } ] }
  let(:resource)   { FactoryGirl.create :function, properties: properties, resource_owner_id: user.id }

  it 'connects to type database' do
    Type.database_name.should == 'types_test'
  end

  it 'creates a function' do
    resource.id.should_not be_nil
  end

  it 'connects the properties' do
    resource.properties.should have(2).items
  end

  it 'belongs to the user' do
    resource.resource_owner_id.should == user.id
  end
end
