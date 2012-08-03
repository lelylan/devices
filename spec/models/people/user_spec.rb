require 'spec_helper'

describe User do

  let(:user) { FactoryGirl.create :user }

  it 'connects to people database' do
    User.database_name.should == 'people_test'
  end

  it 'creates a user' do
    user.id.should_not be_nil
  end
end
