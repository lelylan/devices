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

  describe '#set_type_properties' do

    let(:resource) { FactoryGirl.create :device }

    describe 'when creates a resource' do

      it 'connects two properties' do
        resource.properties.should have(2).items
      end

      describe 'with status' do

        subject { resource.properties.first }

        its(:value)          { should == 'off' }
        its(:expected_value) { should == 'off' }
        its(:pending)        { should == false }
        its(:property_id)    { should_not be_nil }
        its(:id)             { should == resource.properties.first.property_id }
      end

      describe 'with intensity' do

        subject { resource.properties.last }

        its(:value)          { should == '0' }
        its(:expected_value) { should == '0' }
        its(:pending)        { should == false }
        its(:property_id)    { should_not be_nil }
        its(:id)             { should == resource.properties.last.property_id }
      end
    end

    describe 'when updates the resource properties' do

      describe 'when updates the status value' do
        let(:properties) { [ { id: resource.properties.first.id, value: 'on', expected_value: 'off', pending: true } ] }

        before  { resource.update_attributes(properties_attributes: properties) }

        it 'updates its value' do
          resource.properties.first.value.should == 'on'
        end

        it 'updates its physical value' do
          resource.properties.first.expected_value.should == 'off'
        end

        it 'updates its pending status' do
          resource.properties.first.pending.should == true
        end

        it 'does not create new properties' do
          resource.properties.should have(2).items
        end
      end

      describe 'when updates a not existing property value' do
        let(:properties) { [ { id: Settings.resource_id, value: 'on'} ] }
        let(:update)     { resource.properties_attributes = properties }

        it 'raises a not found error' do
          expect { update }.to raise_error Mongoid::Errors::DocumentNotFound
        end
      end
    end
  end

  describe 'when updates the type uri' do

    let!(:resource) { FactoryGirl.create :device }
    let!(:type_id)  { resource.type_id }
    before          { resource.update_attributes(type: a_uri(FactoryGirl.create :type)) }

    it 'does not let the type being updated' do
      resource.reload.type_id.should == type_id
    end
  end

  describe 'when updates a property' do

    let(:resource)    { FactoryGirl.create :device }
    let(:property_id) { resource.properties.first.id }

    describe 'when :pending was false' do

      before { resource.update_attributes(properties_attributes: [{ id: property_id, pending: false }]) }

      describe 'when updates :value' do

        let(:properties) { [ { id: property_id, value: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == false }
      end

      describe 'when updates :expected_value' do

        let(:properties) { [ { id: property_id, expected_value: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == true }
        its(:value)      { should == 'off' }
      end

      describe 'when updates :value and :expected_value' do

        describe 'when they are equal' do
        let(:properties) { [ { id: property_id, value: '100', expected_value: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == false }
        end

        describe 'when they are different' do
        let(:properties) { [ { id: property_id, value: '50', expected_value: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == true }
        end
      end
    end

    describe 'when :pending was true' do

      before { resource.update_attributes(properties_attributes: [{ id: property_id, pending: true, expected_value: '100' }]) }

      describe 'when updates :value' do

        describe 'when :value and :expected_value are equal' do

          let(:properties) { [ { id: property_id, value: '100' } ] }
          before           { resource.update_attributes(properties_attributes: properties) }
          subject          { resource.properties.first }
          its(:pending)    { should == false }
        end

        describe 'when :value and :expected_value are not equal' do

          let(:properties) { [ { id: property_id, value: '50' } ] }
          before           { resource.update_attributes(properties_attributes: properties) }
          subject          { resource.properties.first }
          its(:pending)    { should == true }
        end
      end

      describe 'when updates :expected_value' do

        let(:properties) { [ { id: property_id, expected_value: '50' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == true }
        its(:value)      { should == 'off' }
      end

      describe 'when updates :value and :expected_value' do

        describe 'when they are equal' do
          let(:properties) { [ { id: property_id, value: '100', expected_value: '100' } ] }
          before           { resource.update_attributes(properties_attributes: properties) }
          subject          { resource.properties.first }
          its(:pending)    { should == false }
        end

        describe 'when they are different' do
          let(:properties) { [ { id: property_id, value: '50', expected_value: '100' } ] }
          before           { resource.update_attributes(properties_attributes: properties) }
          subject          { resource.properties.first }
          its(:pending)    { should == true }
        end
      end
    end

    describe 'when a physical device is not connected' do

      before { resource.update_attributes(physical: nil) }

      describe 'when updates :value' do

        let(:properties) { [ { id: property_id, value: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == false }
      end

      describe 'when updates :expected_value' do

        let(:properties) { [ { id: property_id, expected_value: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == false }
        its(:value)      { should == '100' }
      end

      describe 'when updates :value and :expected_value' do

        let(:properties) { [ { id: property_id, value: '50', expected_value: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == false }
      end
    end
  end
end
