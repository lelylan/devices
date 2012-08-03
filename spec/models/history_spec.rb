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

  context 'when creates history properties' do

    let(:status)     { FactoryGirl.build :history_status }
    let(:intensity)  { FactoryGirl.build :history_intensity }
    let(:properties) {[ { uri: a_uri(status), value: 'on' },
                        { uri: a_uri(intensity), value: '0.0' } ]}

    context 'with valid properties' do

      let(:resource) { FactoryGirl.create :history, :with_no_properties, properties: properties }

      it 'creates two properties' do
        resource.properties.should have(2).items
      end
    end

    context 'with pre-existing properties' do

      let(:resource)       { FactoryGirl.create :history }
      let!(:old_status)    { resource.properties.first }
      let!(:old_intensity) { resource.properties.last  }

      before               { resource.update_attributes properties: properties }
      let!(:new_status)    { resource.properties.first }
      let!(:new_intensity) { resource.properties.last  }

      it 'replaces previous properties' do
        new_status.id.should_not    == old_status.id
        new_intensity.id.should_not == old_intensity.id
      end
    end

    context 'with empty properties' do

      let(:resource) { FactoryGirl.create :history, properties: [] }

      it 'removes previous properties' do
        resource.properties.should have(0).items
      end
    end

    context 'with no properties' do

      let(:resource) { FactoryGirl.create :history }
      before         { resource.update_attributes {} }

      it 'does not change anything' do
        resource.properties.should have(2).items
      end
    end

    context 'with not valid property uri' do

      let(:properties) { [{ uri: 'not-valid'} ] } # must live outside as we need to set other mandatory fields
      let(:resource)   { FactoryGirl.create :history, properties: properties } # must live outside as we need to set other mandatory fields

      it 'raises an error' do
        expect { resource }.to raise_error Mongoid::Errors::Validations
      end
    end

    context 'with not valid json' do

      let(:resource) { FactoryGirl.create(:history, properties: 'not-valid') }

      it 'raises an error' do
        expect { resource }.to raise_error
      end
    end
  end
end
