require 'spec_helper'

describe Doorkeeper::AccessToken do

  let(:token) { FactoryGirl.create :access_token }

  it 'connects to people database' do
    Doorkeeper::AccessToken.database_name.should == 'people_test'
  end

  it 'creates an access token' do
    token.id.should_not be_nil
  end
end
