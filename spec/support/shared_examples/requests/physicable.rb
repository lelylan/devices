shared_examples_for 'a forwardable physical request resource' do

  before { FactoryGirl.create :physical } # not used but avoid test error on empty collection
  before { resource.update_attributes(physical: 'http://arduino.casa.com/5cf372d4') }

  it 'creates a physical request' do
    expect { update }.to change { Physical.last.id }
  end

  it 'returns status code 202' do
    update
    page.status_code.should == 202
  end

  describe 'when check physical' do
    before         { update }
    let(:physical) { Physical.last }

    it 'sets the resource id' do
      physical.resource_id.should == resource.id
    end
  end

  describe 'when the there is only :expected_value' do

    let(:properties) { [ { uri: a_uri(status), expected_value: 'updated' } ] }
    before           { update }
    subject          { Hashie::Mash.new Physical.last.data['properties'].last }

    its(:value) { should == 'updated' }
    its(:expected_value) { should == 'updated' }
  end

  describe 'when there is only :value' do
    let(:properties) { [ { uri: a_uri(status), value: 'updated' } ] }
    before           { update }
    subject          { Hashie::Mash.new Physical.last.data['properties'].last }

    its(:value) { should == 'updated' }
    its(:expected_value) { should == nil }
  end

  describe 'when there are :value and :expected_value' do

    let(:properties) { [ { uri: a_uri(status), value: 'updated', expected_value: 'expected_updated' } ] }
    before           { update }
    subject          { Hashie::Mash.new Physical.last.data['properties'].last }

    its(:value) { should == 'updated' }
    its(:expected_value) { should == 'expected_updated' }
  end

  describe 'when the request comes from the physical' do

    let(:signature) { Signature.sign(params, resource.secret) }
    before  { page.driver.header 'X-Physical-Signature', signature }

    it 'does not create a physical request' do
      expect { update }.to_not change { Physical.last.id }
    end

    it 'returns status code 200' do
      update
      page.status_code.should == 200
    end
  end

  describe 'when the resource has not physical connection' do

    before { resource.update_attributes physical: nil }

    it 'does not create a physical request' do
      expect { update }.to_not change { Physical.last.id }
    end

    it 'returns status code 200' do
      update
      page.status_code.should == 200
    end
  end
end