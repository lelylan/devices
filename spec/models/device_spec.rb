require 'spec_helper'

describe Device do

  it { should validate_presence_of :resource_owner_id }
  it { should validate_presence_of :name }
  it { should validate_presence_of :type }
  #it { should validate_presence_of :creator_id }
  #it { should validate_presence_of :secret }
  #it { should validate_presence_of :activation_code }

  its(:pending) { should == false }

  it { Settings.uris.valid.each     { |uri| should allow_value(uri).for(:physical) } }
  it { Settings.uris.not_valid.each { |uri| should_not allow_value(uri).for(:physical) } }

  it { Settings.uris.valid.each     { |uri| should allow_value(uri).for(:type) } }
  it { Settings.uris.not_valid.each { |uri| should_not allow_value(uri).for(:type) } }

  it { should_not allow_mass_assignment_of :resource_owner_id }
  it { should_not allow_mass_assignment_of :creator_id }
  it { should_not allow_mass_assignment_of :type_id }
  it { should_not allow_mass_assignment_of :activated_at }
  it { should_not allow_mass_assignment_of :activation_code }

  it_behaves_like 'a boolean' do
    let(:field)       { 'pending' }
    let(:accepts_nil) { 'false' }
    let(:resource)    { FactoryGirl.create :device }
  end

  describe '#type_id' do

    let(:resource) { FactoryGirl.create :device }
    let(:type)     { Type.find resource.type_id }

    it 'sets the type_id field' do
      resource.type_id.should == type.id
    end
  end

  describe '#activation_code' do

    let(:resource) { FactoryGirl.create :device }

    it 'sets the activation_code field' do
      resource.activation_code.should == Signature.sign(resource.id, resource.secret)
    end
  end

  describe '#synchronize_type_properties' do

    let(:resource) { FactoryGirl.create :device }

    context 'when creates a resource' do

      it 'connects two properties' do
        resource.properties.should have(2).items
      end

      context 'with status' do

        subject { resource.properties.first }

        its(:value)       { should == 'off' }
        its(:property_id) { should_not be_nil }
        its(:id)          { should == resource.properties.first.property_id }
      end

      context 'with intensity' do

        subject { resource.properties.last }

        its(:value)       { should == '0' }
        its(:property_id) { should_not be_nil }
        its(:id)          { should == resource.properties.last.property_id }
      end
    end

    context 'when updates the resource properties' do

      context 'when updates the status value' do
        let(:properties) { [ { id: resource.properties.first.id, value: 'on', physical: 'off' } ] }

        before  { resource.properties_attributes = properties }

        it 'changes its value' do
          resource.properties.first.value.should == 'on'
        end

        it 'changes its physical value' do
          resource.properties.first.physical.should == 'off'
        end

        it 'does not create new properties' do
          resource.properties.should have(2).items
        end
      end

      context 'when updates a not existing property value' do
        let(:properties) { [ { id: Settings.resource_id, value: 'on'} ] }
        let(:update)     { resource.properties_attributes = properties }

        it 'raises a not found error' do
          expect { update }.to raise_error Mongoid::Errors::DocumentNotFound
        end
      end
    end
  end
end
