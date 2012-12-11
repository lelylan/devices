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
        its(:physical_value) { should == 'off' }
        its(:pending)        { should == false }
        its(:property_id)    { should_not be_nil }
        its(:id)             { should == resource.properties.first.property_id }
      end

      describe 'with intensity' do

        subject { resource.properties.last }

        its(:value)          { should == '0' }
        its(:physical_value) { should == '0' }
        its(:pending)        { should == false }
        its(:property_id)    { should_not be_nil }
        its(:id)             { should == resource.properties.last.property_id }
      end
    end

    describe 'when updates the resource properties' do

      describe 'when updates the status value' do
        let(:properties) { [ { id: resource.properties.first.id, value: 'on', physical_value: 'off', pending: true } ] }

        before  { resource.update_attributes(properties_attributes: properties) }

        it 'updates its value' do
          resource.properties.first.value.should == 'on'
        end

        it 'updates its physical value' do
          resource.properties.first.physical_value.should == 'off'
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

  describe 'when Lelyaln automatically updates the pending status' do

    let(:resource) { FactoryGirl.create :device }

    describe 'when a physical device is not present' do

      let(:properties) { [ { id: resource.properties.first.id, value: '100', physical_value: '100' } ] }
      before           { resource.update_attributes(physical: nil, properties_attributes: properties) }
      subject          { resource.properties.first }
      its(:pending)    { should == false }
      its(:pending)    { should == resource.pending }

      describe 'when the pending property is overriden' do

        let(:override) { [ { id: resource.properties.first.id, value: '100', physical_value: '100', pending: true } ] }
        before         { resource.update_attributes(physical: nil, properties_attributes: override) }
        subject        { resource.properties.first }
        its(:pending)  { should == true }
      end
    end

    describe 'when the pending status was false' do

      before { resource.update_attributes(properties_attributes: [{ id: resource.properties.first.id, pending: false}]) }

      describe 'when updates the value' do

        let(:properties) { [ { id: resource.properties.first.id, value: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == true }
        its(:pending)    { should == resource.pending }

        describe 'when the pending property is overriden' do

          let(:override) { [ { id: resource.properties.first.id, value: '100', pending: false } ] }
          before         { resource.update_attributes(properties_attributes: override) }
          subject        { resource.properties.first }
          its(:pending)  { should == false }
        end
      end

      describe 'when updates the physical value' do

        let(:properties) { [ { id: resource.properties.first.id, physical_value: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == false }
        its(:pending)    { should == resource.pending }

        describe 'when the pending property is overriden' do

          let(:override) { [ { id: resource.properties.first.id, physical_value: '100', pending: true } ] }
          before         { resource.update_attributes(properties_attributes: override) }
          subject        { resource.properties.first }
          its(:pending)  { should == true }
        end
      end

      describe 'when updates both value and physical value' do

        describe 'when they are equal' do

          let(:properties) { [ { id: resource.properties.first.id, value: '100', physical_value: '100' } ] }
          before           { resource.update_attributes(properties_attributes: properties) }
          subject          { resource.properties.first }
          its(:pending)    { should == false }
          its(:pending)    { should == resource.pending }

          describe 'when the pending property is overriden' do

            let(:override) { [ { id: resource.properties.first.id, value: '100', physical_value: '100', pending: true } ] }
            before         { resource.update_attributes(properties_attributes: override) }
            subject        { resource.properties.first }
            its(:pending)  { should == true }
          end
        end

        describe 'when they are not equal' do

          let(:properties) { [ { id: resource.properties.first.id, value: '100', physical_value: '10' } ] }
          before           { resource.update_attributes(properties_attributes: properties) }
          subject          { resource.properties.first }
          its(:pending)    { should == true }
          its(:pending)    { should == resource.pending }

          describe 'when the pending property is overriden' do

            let(:override) { [ { id: resource.properties.first.id, value: '100', physical_value: '10', pending: true } ] }
            before         { resource.update_attributes(properties_attributes: override) }
            subject        { resource.properties.first }
            its(:pending)  { should == true }
          end
        end
      end
    end

    describe 'when the pending status was true' do

      before { resource.update_attributes(properties_attributes: [{ id: resource.properties.first.id, value: '100', pending: true }] ) }

      describe 'when updates the value' do

        let(:properties) { [ { id: resource.properties.first.id, value: '100' } ] }
        before           { resource.update_attributes(properties_attributes: properties) }
        subject          { resource.properties.first }
        its(:pending)    { should == true }
        its(:pending)    { should == resource.pending }

        describe 'when the pending property is overriden' do

          let(:override) { [ { id: resource.properties.first.id, value: '100', pending: false } ] }
          before         { resource.update_attributes(properties_attributes: override) }
          subject        { resource.properties.first }
          its(:pending)  { should == false }
        end
      end

      describe 'when updates the physical value' do

        describe 'when equals the value' do

          let(:properties) { [ { id: resource.properties.first.id, physical_value: '100' } ] }
          before           { resource.update_attributes(properties_attributes: properties) }
          subject          { resource.properties.first }
          its(:pending)    { should == false }
          its(:pending)    { should == resource.pending }

          describe 'when the pending property is overriden' do

            let(:override) { [ { id: resource.properties.first.id, physical_value: '100', pending: true } ] }
            before         { resource.update_attributes(properties_attributes: override) }
            subject        { resource.properties.first }
            its(:pending)  { should == true }
          end
        end

        describe 'when does not equal the value' do

          let(:properties) { [ { id: resource.properties.first.id, physical_value: '50' } ] }
          before           { resource.update_attributes(properties_attributes: properties) }
          subject          { resource.properties.first }
          its(:pending)    { should == true }
          its(:pending)    { should == resource.pending }

          describe 'when the pending property is overriden' do

            let(:override) { [ { id: resource.properties.first.id, physical_value: '100', pending: false } ] }
            before         { resource.update_attributes(properties_attributes: override) }
            subject        { resource.properties.first }
            its(:pending)  { should == false }
          end
        end

      end

      describe 'when updates both value and physical value' do

        describe 'when they are equal' do

          let(:properties) { [ { id: resource.properties.first.id, value: '100', physical_value: '100' } ] }
          before           { resource.update_attributes(properties_attributes: properties) }
          subject          { resource.properties.first }
          its(:pending)    { should == false }
          its(:pending)    { should == resource.pending }

          describe 'when the pending property is overriden' do

            let(:override) { [ { id: resource.properties.first.id, value: '100', physical_value: '100', pending: true } ] }
            before         { resource.update_attributes(properties_attributes: override) }
            subject        { resource.properties.first }
            its(:pending)  { should == true }
          end
        end

        describe 'when they are not equal' do

          let(:properties) { [ { id: resource.properties.first.id, value: '100', physical_value: '10' } ] }
          before           { resource.update_attributes(properties_attributes: properties) }
          subject          { resource.properties.first }
          its(:pending)    { should == true }
          its(:pending)    { should == resource.pending }

          describe 'when the pending property is overriden' do

            let(:override) { [ { id: resource.properties.first.id, value: '100', physical_value: '10', pending: true } ] }
            before         { resource.update_attributes(properties_attributes: override) }
            subject        { resource.properties.first }
            its(:pending)  { should == true }
          end
        end
      end
    end
  end
end
