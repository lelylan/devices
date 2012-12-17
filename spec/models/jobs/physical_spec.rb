require 'spec_helper'

describe Physical do

  let(:resource) { FactoryGirl.create :physical }

  it 'connects to jobs database' do
    Event.database_name.should == 'jobs_test'
  end

  it 'keeps the id' do
    resource.id.should_not be_nil
  end

  it { should validate_presence_of :data }
end
