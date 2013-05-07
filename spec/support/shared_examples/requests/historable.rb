shared_examples_for 'a historable resource' do

  it 'adds a new history record' do
    expect { update }.to change { History.count }.by(1)
  end

  describe 'when saving the device properties' do

    before        { update }
    let(:history) { History.last }

    it 'saves the device properties' do
      history.device_id.should == resource.id
    end

    it 'saves the new status value' do
      history.properties.first.value.should == 'on'
    end

    it 'does not come form the physical world' do
      history.source.should == 'lelylan'
    end

    before { page.driver.header 'X-Physical-Secret', resource.secret }

    describe 'with a physical request' do

      before { page.driver.put uri, params.to_json }

      it 'comes form the physical world' do
        history.source.should == 'physical'
      end
    end
  end
end
