require 'spec_helper'

describe Doorkeeper::Application do

  let(:application) { FactoryGirl.create :application }

  it 'connects to people database' do
    Doorkeeper::Application.database_name.should == 'people_test'
  end

  it 'creates an application' do
    application.id.should_not be_nil
  end
end
