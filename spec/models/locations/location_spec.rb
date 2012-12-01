require 'spec_helper'

describe Location do

  let(:user)     { FactoryGirl.create :user }
  let(:resource) { FactoryGirl.create :location, :with_devices, resource_owner_id: user.id }

  it 'connects to location database' do
    Location.database_name.should == 'locations_test'
  end

  it 'creates a location' do
    resource.id.should_not be_nil
  end

  it 'contains a device' do
    resource.device_ids.should_not be_empty
  end

  it 'belongs to the user' do
    resource.resource_owner_id.should == user.id
  end
end
