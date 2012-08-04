#require 'spec_helper'

#describe DeviceProperty do

  #it { should validate_presence_of :uri }

  #it { Settings.uris.valid.each     { |uri| should allow_value(uri).for(:uri) } }
  #it { Settings.uris.not_valid.each { |uri| should_not allow_value(uri).for(:uri) } }

  #it { should_not allow_mass_assignment_of :property_id }

  ## in this way we can use the device factory as defined without changes
  #before { Device.any_instance.stub(:synchronize_type).and_return(true) }

  #it_behaves_like 'a resource connection', 'between device and property' do
    #let(:connection_resource) { FactoryGirl.create :status }
    #let(:connection_params)   { [ { uri: a_uri(connection_resource), value: 'on' } ] }
    #let(:changing_attribute)  { 'value'}
  #end
#end
