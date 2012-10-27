require 'spec_helper'

describe Event do

  let(:resource) { FactoryGirl.create :event }

  it 'connects to jobs database' do
    Event.database_name.should == 'jobs_test'
  end

  it 'creates a device' do
    resource.id.should_not be_nil
  end

  it { should validate_presence_of :resource }
  it { should validate_presence_of :event }
  it { should validate_presence_of :data }
end
