require 'spec_helper'

describe HistoryProperty do

  it { should validate_presence_of :uri }
  it { should validate_presence_of :value }

  it { Settings.uris.valid.each     { |uri| should allow_value(uri).for(:uri) } }
  it { Settings.uris.not_valid.each { |uri| should_not allow_value(uri).for(:uri) } }

  it { should_not allow_mass_assignment_of :property_id }

  it_behaves_like 'a resource connection', 'between history and property' do
    let(:connection_resource) { FactoryGirl.create :status }
    let(:connection_params)   { [ { uri: a_uri(connection_resource), value: 'on' } ] }
  end
end
