require 'spec_helper'

describe Consumption do

  it { should validate_presence_of :resource_owner_id }
  it { should validate_presence_of :device }
  it { should validate_presence_of :value }

  its(:type)     { should == 'instantaneous' }
  its(:unit)     { should == 'kwh' }
  its(:occur_at) { should_not be_nil }

  it { Settings.uris.valid.each     { |uri| should allow_value(uri).for(:device) } }
  it { Settings.uris.not_valid.each { |uri| should_not allow_value(uri).for(:device) } }

  it { ['instantaneous', 'durational'].each { |type| should allow_value(type).for(:type) } }
  it { ['not-valid'].each { |type| should_not allow_value(type).for(:type) } }

  it { should_not allow_mass_assignment_of :resource_owner_id }
  it { should_not allow_mass_assignment_of :device_id }

  describe '#device_id' do

    let(:consumption) { FactoryGirl.create :consumption }

    it 'sets the device_id field' do
      consumption.device_id.should == Moped::BSON::ObjectId(Settings.resource_id)
    end
  end

  describe '#normalize_timings' do

    context 'with durational consumption' do

      let(:valid) { FactoryGirl.create :consumption, :durational }

      context 'with all timing values' do
        let(:consumption) { FactoryGirl.create :consumption, :durational }

        it 'does not change timing fields' do
          consumption.occur_at.should == valid.occur_at
          consumption.end_at.should   == valid.end_at
          consumption.duration.should == valid.duration
        end
      end

      context 'when misses the duration field' do

        let(:consumption) { FactoryGirl.create :consumption, :durational, duration: nil }

        it 'calculates the duration field' do
          consumption.duration.should == valid.duration
        end
      end

      context 'when misses the end_at field' do

        let(:consumption) { FactoryGirl.create :consumption, :durational, end_at: nil }

        it 'calculates the end_at field' do
          consumption.end_at.should have_the_same_time_as valid.end_at
        end
      end

      context 'when misses the occur_at field' do

        let(:consumption) { FactoryGirl.create :consumption, :durational, occur_at: nil }

        it 'calculates the occur_at field' do
          consumption.occur_at.should have_the_same_time_as valid.occur_at
        end
      end

      context 'when misses two timing fields' do

        let(:consumption) { FactoryGirl.create :consumption, :durational, occur_at: nil, duration: nil }

        it 'raises an error' do
          expect { consumption }.to raise_error Mongoid::Errors::Validations
        end
      end
    end

    context 'with instantaneous consumption' do

      let(:consumption) { FactoryGirl.create :consumption }

      it 'does not normalize durational fields' do
        consumption.end_at.should   be_nil
        consumption.duration.should be_nil
      end
    end
  end
end
