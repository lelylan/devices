require 'spec_helper'

describe Device do

  it { should validate_presence_of :resource_owner_id }
  it { should validate_presence_of :name }
  it { should validate_presence_of :type }

  its(:pending) { should == false }

  it { Settings.uris.valid.each     { |uri| should allow_value(uri).for(:type) } }
  it { Settings.uris.not_valid.each { |uri| should_not allow_value(uri).for(:type) } }

  it { should_not allow_mass_assignment_of :resource_owner_id }
  it { should_not allow_mass_assignment_of :type_id }

  it_behaves_like 'a boolean' do
    let(:field)       { 'pending' }
    let(:accepts_nil) { 'false' }
    let(:resource)    { FactoryGirl.create :device }
  end

  describe '#synchronize_type' do

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

        it 'changes value' do
          resource.properties.first.value.should == 'on'
        end

        it 'changes pending value' do
          resource.properties.first.physical.should == 'off'
        end

        it 'does not connect new properties' do
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
        before { resource.synchronize_type }

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
        before { resource.synchronize_type }

        it 'removes the intensity property from the device' do
          resource.properties.should have(1).items
        end

        it 'does not remove previous changes' do
          resource.properties.first.value.should == 'on'
        end
      end
    end
  end
end












## -------------------------------
## Syncronize to physical device
## -------------------------------
#context '#synchronize_device' do
#before { @properties = json_fixture('properties.json')[:properties] }

#context 'with physical connection' do
#before  { stub_request(:put, Settings.physical.uri).with(body: {properties: @properties}) }
#before  { @device = FactoryGirl.create(:device) }
#before  { @device.synchronize_device(@properties, {}) }

#it 'should change device property status' do
#@device.reload.device_properties[0][:value].should == 'on'
#end

#it 'should change device property intensity' do
#@device.reload.device_properties[1][:value].should == '100.0'
#end

#it 'should update the physical device' do
#a_put(Settings.physical.uri, false).with(body: {properties: @properties}).should have_been_made.once
#end
#end

#context 'without physical connection' do
#before  { @device = FactoryGirl.create(:device_no_physical) }
#before  { @device.synchronize_device(@properties, {}) }

#it 'should change device property status' do
#@device.reload.device_properties[0][:value].should == 'on'
#end

#it 'should change device property intensity' do
#@device.reload.device_properties[1][:value].should == '100.0'
#end

#it 'should not update the physical device' do
#a_put(Settings.physical.uri, false).with(body: {properties: @properties}).should_not have_been_made
#end
#end

#context 'with source: 'physical'' do
#before  { @device = FactoryGirl.create(:device_no_physical) }
#before  { @device.synchronize_device(@properties, {source: 'physical'}) }

#it 'should not update the physical device' do
#a_put(Settings.physical.uri, false).with(body: {properties: @properties}).should_not have_been_made
#end
#end
#end


## ----------------
## Create history
## ----------------

#context '#create_history' do
#before { @device = DeviceDecorator.decorate(FactoryGirl.create(:device_no_physical)) }
#before { DeviceDecorator.any_instance.stub(:uri).and_return(Settings.device.uri) }

#it 'should create an history' do
#expect{ @device.create_history(Settings.user.another.uri) }.to change{ History.count }.by(1)
#history = History.last
#history.device_uri.should == @device.uri
#history.created_from.should == Settings.user.another.uri
#history.history_properties.should have(2).items
#end
#end


## ----------------
## Update pending
## ----------------
#context '#update_pending' do
#before { DeviceDecorator.any_instance.stub(:uri).and_return(Settings.device.uri) }
#before { @params = json_fixture('properties.json') }

## -----------------------------
## With no physical connection
## -----------------------------
#context 'with no physical connection' do
#before { @device = DeviceDecorator.decorate(FactoryGirl.create(:device_no_physical)) }

#context 'when update device properties' do
#before { @device.synchronize_device(@params[:properties], @params) }

#it 'should not be pending' do
#@device.pending.should be_false
#end
#end
#end

## --------------------------
## With physical connection
## --------------------------
#context 'with physical connection' do
#before { stub_request(:put, Settings.physical.uri) }
#before { @device = DeviceDecorator.decorate(FactoryGirl.create(:device)) }

## -----------------------------
## Create pending (from user)
## -----------------------------
#context 'when pending: 'start'' do
#before { @params[:pending] = 'start' }

#context 'when update properties' do
#before { @device.synchronize_device(@params[:properties], @params) }

#it 'should be pending' do
#@device.pending.should be_true
#end

#it 'should update device properties' do
#@device.device_properties[0].value.should == 'on'
#@device.device_properties[1].value.should == '100.0'
#end

#it 'should have old property values as pending values' do
#@device.device_properties[0].pending.should == 'off'
#@device.device_properties[1].pending.should == '0.0'
#end
#end
#end

## --------------------------------
## Update pending (from physical)
## --------------------------------
#context 'when pending: 'update'' do
#before { @params[:pending] = 'update' }
#before { @params[:properties][1][:value] = '75.0' }

#context 'when update properties' do
#before { @device.synchronize_device(@params[:properties], @params) }

#it 'should be pending' do
#@device.pending.should be_true
#end

#it 'should not update property values' do
#@device.device_properties[0].value.should == 'off'
#@device.device_properties[1].value.should == '0.0'
#end

#it 'should update pending values' do
#@device.device_properties[0].pending.should == 'on'
#@device.device_properties[1].pending.should == '75.0'
#end
#end
#end

## -------------------------------
## Close pending (from physical)
## -------------------------------
#context 'when pending: 'close'' do
#before { @params[:pending] = 'close' }

#context 'when update properties' do
#before { @device.synchronize_device(@params[:properties], @params) }

#it 'should not be pending' do
#@device.pending.should_not be_true
#end

#it 'should update property values' do
#@device.device_properties[0].pending.should == 'on'
#@device.device_properties[1].pending.should == '100.0'
#end

#it 'should update pending values' do
#@device.device_properties[0].value.should == 'on'
#@device.device_properties[1].value.should == '100.0'
#end
#end
#end
#end
#end

#end
