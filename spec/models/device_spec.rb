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

        its(:value)       { should == 'off' }
        its(:expected)    { should == 'off' }
        its(:pending)     { should == false }
        its(:suggested)   { should == { 'on' => 'On', 'off' => 'Off' } }
        its(:property_id) { should_not be_nil }
        its(:id)          { should == resource.properties.first.property_id }
      end

      describe 'with intensity' do

        subject { resource.properties.last }

        its(:value)       { should == '0' }
        its(:expected)    { should == '0' }
        its(:pending)     { should == false }
        its(:property_id) { should_not be_nil }
        its(:suggested)   { should == { '0' => 'min', '50' => 'half', '100' => 'max' } }
        its(:id)          { should == resource.properties.last.property_id }
      end
    end

    describe 'when updates the resource properties' do

      describe 'when updates the status value' do
        let(:properties) { [ { id: resource.properties.first.id, value: 'on', expected: 'off', pending: true, suggested: { 'updated' => 'updated' } } ] }

        before  { resource.update_attributes(properties_attributes: properties) }

        it 'updates its value' do
          resource.properties.first.value.should == 'on'
        end

        it 'updates its physical value' do
          resource.properties.first.expected.should == 'off'
        end

        it 'updates its pending status' do
          resource.properties.first.pending.should == true
        end

        it 'updates its suggested values' do
          resource.properties.first.suggested.should == { 'updated' => 'updated' }
        end

        it 'does not create new properties' do
          resource.properties.should have(2).items
        end
      end

      describe 'when updates a not existing property' do
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

    it 'does not apply the type update' do
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
        its(:expected)   { should == '100' }
        its(:value)      { should == '100' }
      end

      describe 'when updates :expected' do

        let(:properties) { [ { id: property_id, expected: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == true }
        its(:value)      { should == 'off' }
        its(:expected)   { should == '100' }
      end

      describe 'when updates :value and :expected' do

        describe 'when they are equal' do
        let(:properties) { [ { id: property_id, value: '100', expected: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == false }
        its(:value)      { should == '100' }
        its(:expected)   { should == '100' }
        end

        describe 'when they are different' do
        let(:properties) { [ { id: property_id, value: '50', expected: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == true }
        its(:value)      { should == '50' }
        its(:expected)   { should == '100' }
        end
      end
    end

    describe 'when :pending was true' do

      before { resource.update_attributes(properties_attributes: [{ id: property_id, pending: true, expected: '100' }]) }

      describe 'when updates :value' do

        describe 'when :value and :expected are equal' do

          let(:properties) { [ { id: property_id, value: '100' } ] }
          before           { resource.update_attributes(properties_attributes: properties) }
          subject          { resource.properties.first }
          its(:pending)    { should == false }
          its(:value)      { should == '100' }
          its(:expected)   { should == '100' }
        end

        describe 'when :value and :expected are not equal' do

          let(:properties) { [ { id: property_id, value: '50' } ] }
          before           { resource.update_attributes(properties_attributes: properties) }
          subject          { resource.properties.first }
          its(:pending)    { should == true }
          its(:value)      { should == '50' }
          its(:expected)   { should == '100' }
        end
      end

      describe 'when updates :expected' do

        let(:properties) { [ { id: property_id, expected: '50' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == true }
        its(:value)      { should == 'off' }
        its(:expected)   { should == '50' }
      end

      describe 'when updates :value and :expected' do

        describe 'when they are equal' do
          let(:properties) { [ { id: property_id, value: '100', expected: '100' } ] }
          before           { resource.update_attributes(properties_attributes: properties) }
          subject          { resource.properties.first }
          its(:pending)    { should == false }
          its(:value)      { should == '100' }
          its(:expected)   { should == '100' }
        end

        describe 'when they are different' do
          let(:properties) { [ { id: property_id, value: '50', expected: '100' } ] }
          before           { resource.update_attributes(properties_attributes: properties) }
          subject          { resource.properties.first }
          its(:pending)    { should == true }
          its(:value)      { should == '50' }
          its(:expected)   { should == '100' }
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
        its(:value)      { should == '100' }
        its(:expected)   { should == '100' }
      end

      describe 'when updates :expected' do

        let(:properties) { [ { id: property_id, expected: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == false }
        its(:value)      { should == '100' }
        its(:expected)   { should == '100' }
      end

      describe 'when updates :value and :expected' do

        let(:properties) { [ { id: property_id, value: '50', expected: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == false }
        its(:value)      { should == '50' }
        its(:expected)   { should == '100' }
      end
    end
  end
end
