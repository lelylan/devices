require 'spec_helper'

describe HistoryProperty do

  it { should validate_presence_of :uri }

  it { Settings.uris.valid.each     { |uri| should allow_value(uri).for(:uri) } }
  it { Settings.uris.not_valid.each { |uri| should_not allow_value(uri).for(:uri) } }

  it { should_not allow_mass_assignment_of :property_id }

  context 'when creates history properties' do

    let(:status)     { FactoryGirl.build :history_property }
    let(:properties) {[ { uri: a_uri(status), value: 'on' } ]}
    let(:history)    { FactoryGirl.create :history, properties: properties }
    let(:resource)   { history.properties.first }

      it 'creates two properties' do
        resource.property_id.should == status.id
      end
  end
end
