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

    context 'when updates the resource type' do

      let(:type) { Type.find resource.type_id }

      let(:properties) { [ { id: resource.properties.first.id, value: 'on'} ] }
      before           { resource.properties_attributes = properties }

      context 'with a new property' do

        let(:property)     { FactoryGirl.create :property, default: 'undefined' }
        let(:property_ids) { type.property_ids << property.id }

        before { type.update_attributes property_ids: property_ids }
        before { resource.synchronize_type_properties }

        it 'adds the new property to the device' do
          resource.properties.should have(3).items
        end

        it 'sets the default value' do
          resource.properties.last.value.should == 'undefined'
        end

        it 'does not remove previous changes' do
          resource.properties.first.value.should == 'on'
        end
      end

      context 'with one property less' do

        before { type.update_attributes property_ids: [ type.property_ids.first ] }
        before { resource.synchronize_type_properties }

        it 'removes the intensity property from the device' do
          resource.properties.should have(1).items
        end

        it 'does not remove previous changes' do
          resource.properties.first.value.should == 'on'
        end
      end
    end
  end

  describe '#synchronize_function_properties' do

    let(:resource)  { FactoryGirl.create :device }
    let(:type)      { Type.find resource.type_id }
    let(:status)    { Property.find resource.properties.first.id }
    let(:intensity) { Property.find resource.properties.last.id }

    context 'with pre-completed function (turn on)' do

      let(:properties)   { [ { uri: a_uri(status), value: 'on' } ] }
      let(:function)     { FactoryGirl.create :function, properties: properties }
      let(:function_uri) { a_uri function }

      context 'when does not override function property value' do

        before { resource.synchronize_function_properties function_uri }

        it 'updates the status value' do
          resource.properties.first.value.should == 'on'
        end
      end

      context 'when overrides function property value' do

        let(:override) { [ id: status.id, value: 'override' ]  }

        before { resource.synchronize_function_properties function_uri, override }

        it 'overrides the status value' do
          resource.properties.first.value.should == 'override'
        end
      end
    end

    context 'with not pre-completed function' do

      let(:properties)   { [ { uri: a_uri(status), value: 'on' }, { uri: a_uri(intensity) } ] }
      let(:function)     { FactoryGirl.create :function, properties: properties }
      let(:function_uri) { a_uri function }

      context 'when sends missing function property values' do

        let(:override) { [ {id: intensity.id, value: '20' } ] }

        before { resource.synchronize_function_properties function_uri, override }

        it 'updates the status value' do
          resource.properties.first.value.should == 'on'
        end

        it 'updates the intensity value' do
          resource.properties.last.value.should == '20'
        end
      end

      context 'when does not send missing function property values' do

        before { resource.synchronize_function_properties function_uri }

        it 'updates the status value' do
          resource.properties.first.value.should == 'on'
        end

        it 'does not update the intensity value' do
          resource.properties.last.value.should be_nil
        end
      end
    end

    context 'with not valid function uri' do

      let(:execute) { resource.synchronize_function_properties 'not-valid' }

      it 'sould raise an error' do
        expect { execute }.to raise_error Mongoid::Errors::DocumentNotFound
      end
    end
  end

  describe '#device_properties' do

    let(:resource)   { FactoryGirl.create :device }
    let(:type)       { Type.find resource.type_id }
    let(:status)     { Property.find resource.properties.first.id }
    let(:intensity)  { Property.find resource.properties.last.id }
    let(:properties) { [ { uri: a_uri(status), value: 'on' }, { uri: a_uri(intensity), physical: '20' } ] }

    context 'with status' do

      let(:parsed) { resource.device_properties(properties).first }

      it { parsed[:id].should == status.id.to_s }
      it { parsed[:value].should == 'on' }
      it { parsed.should_not have_key(:physical) }
    end

    context 'with intensity' do

      let(:parsed) { resource.device_properties(properties).last }

      it { parsed[:id].should  == intensity.id.to_s }
      it { parsed.should_not have_key(:value) }
      it { parsed[:physical].should == '20' }
    end
  end
end
