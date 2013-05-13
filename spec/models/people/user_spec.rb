require 'spec_helper'

describe User do

  let(:user) { FactoryGirl.create :user }

  it 'connects to people database' do
    User.database_name.should == 'people_test'
  end

  it 'creates a user' do
    user.id.should_not be_nil
  end

  describe '#description' do

    describe 'when has email' do

      before { user.update_attributes(username: nil, full_name: nil) }

      it 'get the email' do
        user.description.should == 'alice@example.com'
      end
    end

    describe 'when has username' do

      before { user.update_attributes(full_name: nil) }

      it 'get the email' do
        user.description.should == 'alice'
      end
    end

    describe 'when has fullname' do

      it 'get the email' do
        user.description.should == 'Alice Wonderland'
      end
    end
  end
end
