require 'spec_helper'

describe Function do

  let(:resource) { FactoryGirl.build :status_for_function }

  it 'connects to type database' do
    Type.database_name.should == 'types_test'
  end
end
