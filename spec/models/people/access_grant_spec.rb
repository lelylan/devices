require 'spec_helper'

describe Doorkeeper::AccessGrant do

  let(:token) { FactoryGirl.create :access_grant }

  it 'connects to people database' do
    Doorkeeper::AccessGrant.database_name.should == 'people_test'
  end

  it 'creates an access grant' do
    token.id.should_not be_nil
  end
end
