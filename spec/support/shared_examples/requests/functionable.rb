shared_examples_for 'a functionable resource' do

  describe 'when executes a pre-defined function like turn on' do

    let(:properties)   { [ { id: status.id, value: 'on' } ] }
    let(:function)     { FactoryGirl.create :function, properties: properties }

    describe 'when does not override any function property value' do

      let(:params) { { pending: true, properties: nil, function: { id: function.id } } }

      before { update }

      it 'updates the status value' do
        resource.reload.properties.first.value.should == 'on'
      end
    end

    describe 'when overrides a function property value' do

      let(:override) { [ id: status.id, value: 'override' ]  }
      let(:params)   { { pending: true, properties: override, function: { id: function.id } } }

      before { update }

      it 'overrides the status value' do
        resource.reload.properties.first.value.should == 'override'
      end
    end
  end

  describe 'with executes not pre-defined function like set intensity' do

    let(:properties)   { [ { id: status.id, value: 'on' }, { id: intensity.id } ] }
    let(:function)     { FactoryGirl.create :function, properties: properties }

    describe 'when sends missing function property values' do

      let(:override) { [ { id: intensity.id, value: '20' } ] }
      let(:params)   { { pending: true, properties: override, function: { id: function.id } } }

      before { update }

      it 'updates the status value' do
        resource.reload.properties.first.value.should == 'on'
      end

      it 'updates the intensity value' do
        resource.reload.properties.last.value.should == '20'
      end
    end

    describe 'when does not send missing function property values' do

      before { update }

      it 'updates the status value' do
        resource.reload.properties.first.value.should == 'on'
      end

      it 'does not update the intensity value' do
        resource.reload.properties.last.value.should == '0'
      end
    end
  end

  context 'with not valid function id' do

    let(:params) { { pending: true, properties: properties, function: { id: 'not-valid' } } }

    before { update }

    it 'should raise an error' do
      has_not_found_resource code: 'notifications.function.not_found'
    end
  end
end
