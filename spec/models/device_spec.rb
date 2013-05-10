require 'spec_helper'

describe Device do

  it { should validate_presence_of :resource_owner_id }
  it { should validate_presence_of :name }
  it { should validate_presence_of :maker_id }

  its(:pending) { should == false }

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

  describe '#physical' do

    let(:resource) { FactoryGirl.create :device }

    it 'sets the physical field' do
      resource.physical[:uri].should == "http://arduino.casa.com/#{resource.id}"
    end
  end

  describe '#activation_code' do

    let(:resource) { FactoryGirl.create :device }

    it 'sets the activation_code field' do
      resource.activation_code.should == Signature.sign(resource.id, resource.secret)
    end
  end

  describe '#categories' do

    let(:resource) { FactoryGirl.create :device }

    it 'sets the categories field' do
      resource.categories.should == ['lights']
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
        its(:property_id) { should_not be_nil }
        its(:id)          { should == resource.properties.first.property_id }
      end

      describe 'with intensity' do

        subject { resource.properties.last }

        its(:value)       { should == '0' }
        its(:expected)    { should == '0' }
        its(:pending)     { should == false }
        its(:property_id) { should_not be_nil }
        its(:id)          { should == resource.properties.last.property_id }
      end
    end

    describe 'when updates the resource properties' do

      describe 'when updates the status value' do
        let(:properties) { [ { id: resource.properties.first.id, value: 'value', expected: 'expected', pending: false, accepted: { 'updated' => 'updated' } } ] }

        before  { resource.update_attributes(properties_attributes: properties) }

        it 'updates its value' do
          resource.properties.first.value.should == 'value'
        end

        it 'updates its physical value' do
          resource.properties.first.expected.should == 'expected'
        end

        it 'updates its pending status' do
          resource.properties.first.pending.should == false
        end

        it 'updates its accepted values' do
          resource.properties.first.accepted.should == { 'updated' => 'updated' }
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

    #describe 'when #pending was false' do

      #before { resource.update_attributes(properties_attributes: [{ id: property_id, pending: false }]) }

      #describe 'when updates #value' do

        #let(:properties) { [ { id: property_id, value: 'on' } ] }
        #before           { resource.update_attributes(properties_attributes: properties) }
        #subject          { resource.properties.first }

        #its(:pending)    { should == false }
        #its(:value)      { should == 'on' }
        #its(:expected)   { should == 'on' }
      #end

      #describe 'when updates #value and #pending true' do

        #let(:properties) { [ { id: property_id, value: 'on', pending: true } ] }
        #before           { resource.update_attributes(properties_attributes: properties) }
        #subject          { resource.properties.first }

        #its(:pending)    { should == true }
        #its(:value)      { should == 'off' }
        #its(:expected)   { should == 'on' }
      #end

      #describe 'when updates #value and #pending false' do

        #let(:properties) { [ { id: property_id, value: 'on', pending: false } ] }
        #before           { resource.update_attributes(properties_attributes: properties) }
        #subject          { resource.properties.first }

        #its(:pending)    { should == false }
        #its(:value)      { should == 'on' }
        #its(:expected)   { should == 'on' }
      #end
    #end

    describe 'when #pending was true' do

      before { resource.update_attributes(properties_attributes: [{ id: property_id, pending: true }]) }

      # TODO BUG https://groups.google.com/forum/?fromgroups=#!topic/mongoid/yU7Fmg4mB5s
      #describe 'when updates #value' do

        #let(:properties) { [ { id: property_id, value: 'on' } ] }
        #before           { resource.update_attributes(properties_attributes: properties) }
        #subject          { resource.properties.first }

        #its(:pending)    { should == false }
        #its(:expected)   { should == 'on' }
        #its(:value)      { should == 'on' }
      #end

      #describe 'when updates #value and #pending true' do

        #let(:properties) { [ { id: property_id, value: 'on', pending: true } ] }
        #before           { resource.update_attributes(properties_attributes: properties) }
        #subject          { resource.properties.first }

        #its(:pending)    { should == true }
        #its(:value)      { should == 'off' }
        #its(:expected)   { should == 'on' }
      #end

      #describe 'when updates #value and #pending false' do

        #let(:properties) { [ { id: property_id, value: 'on', pending: false } ] }
        #before           { resource.update_attributes(properties_attributes: properties) }
        #subject          { resource.properties.first }

        #its(:pending)    { should == false }
        #its(:value)      { should == 'on' }
        #its(:expected)   { should == 'on' }
      #end
    end

    describe 'when a physical device is not connected' do

      before { resource.update_attributes(physical: nil) }

      describe 'when updates #value' do

        let(:properties) { [ { id: property_id, value: 'on' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }

        its(:pending)    { should == false }
        its(:value)      { should == 'on' }
        its(:expected)   { should == 'on' }
      end

      describe 'when updates #value and #pending true' do

        let(:properties) { [ { id: property_id, value: 'on', pending: true } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }

        its(:pending)    { should == false }
        its(:value)      { should == 'on' }
        its(:expected)   { should == 'on' }
      end

      describe 'when updates #value and #pending false' do

        let(:properties) { [ { id: property_id, value: 'on', pending: false } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }

        its(:pending)    { should == false }
        its(:value)      { should == 'on' }
        its(:expected)   { should == 'on' }
      end
    end
  end
end
