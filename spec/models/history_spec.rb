require 'spec_helper'

describe History do

  it { should validate_presence_of :resource_owner_id }
  it { should validate_presence_of :device }

  it { Settings.uris.valid.each     {|uri| should allow_value(uri).for(:device)} }
  it { Settings.uris.not_valid.each {|uri| should_not allow_value(uri).for(:device)} }

  it { should_not allow_mass_assignment_of :resource_owner_id }
  it { should_not allow_mass_assignment_of :device_id }

  describe '#device_id' do

    let(:resource) { FactoryGirl.create :history }

    it 'sets the device_id field' do
      resource.device_id.should == Moped::BSON::ObjectId(Settings.resource_id)
    end
  end
end
