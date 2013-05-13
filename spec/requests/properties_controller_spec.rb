require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'PropertiesController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'devices' }
  let(:factory)    { 'device' }

  context 'PUT /devices/:id/properties' do

    let(:resource)   { FactoryGirl.create :device, :with_no_physical, resource_owner_id: user.id }
    let(:status)     { Property.find resource.properties.first.id }
    let(:intensity)  { Property.find resource.properties.last.id }
    let(:properties) { [ { id: status.id, value: 'on' }, { id: intensity.id, value: 'updated' } ] }
    let(:params)     { { properties: properties } }
    let(:update)     { page.driver.put uri, params.to_json }

    let(:uri) { "/devices/#{resource.id}/properties" }

    it_behaves_like 'an updatable resource'
    it_behaves_like 'an updatable resource from physical'
    it_behaves_like 'a sourceable resource'
    it_behaves_like 'a forwardable physical request resource'
    it_behaves_like 'a historable resource'
    it_behaves_like 'a not owned resource', 'page.driver.put(uri)'
    it_behaves_like 'a not found resource', 'page.driver.put(uri)'
    it_behaves_like 'a filterable resource', 'page.driver.put(uri)'
    it_behaves_like 'a registered event', 'page.driver.put(uri, params.to_json)', nil, 'devices', 'property-update'

    it 'touches the device' do
      resource.updated_at = Time.now - 60; resource.save
      expect { update }.to change { resource.reload.updated_at.to_i }
    end

    describe 'when creates an event' do

      before { update }

      it 'has two properties' do
        Event.last.data['properties'].should have(2).properties
      end

      it 'saves the updated properties' do
        Event.last.data['properties'].first['value'].should == 'on'
      end
    end

    describe 'when updates a not existing property' do

      let(:another) { FactoryGirl.create :property }
      let(:params)  { { properties: [ { id: another.id, value: 'not-valid' } ] } }

      it 'raises a not found property' do
        page.driver.put(uri, params.to_json)
        has_not_found_resource uri: params[:properties].map { |p| p[:uri] }, code: 'notifications.property.not_found'
      end

      it 'does not create an history resource' do
        expect { update }.to_not change { History.count }.by(1)
      end

      it 'does not create an event resource' do
        expect { update }.to_not change { Event.count }.by(1)
      end
    end

    describe '#pending' do

      let(:property_id) { resource.properties.first.id }

      describe 'with a connected physical device' do

        before { resource.update_attributes(physical: { uri: 'http://arduino.casa.com' }) }

        describe 'when is false' do

          before { resource.update_attributes(properties_attributes: [{ id: property_id, pending: false }]) }

          describe 'when updates #value' do

            let(:params) { { properties: [{ id: property_id, value: 'on' }] } }
            before       { update }
            subject      { resource.reload.properties.first }

            its(:pending)  { should == false }
            its(:value)    { should == 'on' }
            its(:expected) { should == 'on' }
          end

          describe 'when updates #value and #pending as true' do

            let(:params) { { properties: [{ id: property_id, value: 'on', pending: true }] } }
            before       { update }
            subject      { resource.reload.properties.first }

            its(:pending)  { should == true }
            its(:value)    { should == 'on' }
            its(:expected) { should == 'off' }
          end

          describe 'when updates #expected and #pending as true' do

            let(:params) { { properties: [{ id: property_id, expected: 'on', pending: true }] } }
            before       { update }
            subject      { resource.reload.properties.first }

            its(:pending)  { should == true }
            its(:value)    { should == 'off' }
            its(:expected) { should == 'on' }
          end

          describe 'when updates #value, #expected and #pending as true' do

            let(:params) { { properties: [{ id: property_id, value: 'on', expected: 'off', pending: true }] } }
            before       { update }
            subject      { resource.reload.properties.first }

            its(:pending)  { should == true }
            its(:value)    { should == 'on' }
            its(:expected) { should == 'off' }
          end
        end

        describe 'when is true' do

          before { resource.update_attributes(properties_attributes: [{ id: property_id, pending: true }]) }

          describe 'when updates #value' do

            let(:params) { { properties: [{ id: property_id, value: 'on' }] } }
            before       { update }
            subject      { resource.reload.properties.first }

            its(:pending)  { should == false }
            its(:value)    { should == 'on' }
            its(:expected) { should == 'on' }
          end

          # -> Physical - In this case we only update the physical device #value
          describe 'when updates #value and #pending as true' do

            let(:params) { { properties: [{ id: property_id, value: 'on', pending: true }] } }
            before       { update }
            subject      { resource.reload.properties.first }

            its(:pending)  { should == true }
            its(:value)    { should == 'on' }
            its(:expected) { should == 'off' }
          end

          # -> UI - In this case we want to apply the new property changes
          describe 'when updates #expected and #pending as true' do

            let(:params) { { properties: [{ id: property_id, expected: 'on', pending: true }] } }
            before       { update }
            subject      { resource.reload.properties.first }

            its(:pending)  { should == true }
            its(:value)    { should == 'off' }
            its(:expected) { should == 'on' }
          end

          describe 'when updates #value, #expected and #pending as false' do

            let(:params) { { properties: [{ id: property_id, value: 'on', expected: 'on', pending: false }] } }
            before       { update }
            subject      { resource.reload.properties.first }

            its(:pending)  { should == false }
            its(:value)    { should == 'on' }
            its(:expected) { should == 'on' }
          end
        end
      end

      describe 'with a not connected physical device' do

        describe 'when updates #value' do

          let(:params) { { properties: [{ id: property_id, value: 'on' }] } }
          before       { update }
          subject      { resource.reload.properties.first }

          its(:pending)  { should == false }
          its(:value)    { should == 'on' }
          its(:expected) { should == 'on' }
        end

        describe 'when updates #value and #pending as true' do

          let(:params) { { properties: [{ id: property_id, value: 'on', pending: true }] } }
          before       { update }
          subject      { resource.reload.properties.first }

          its(:pending)  { should == true }
          its(:value)    { should == 'on' }
          its(:expected) { should == 'on' }
        end

        describe 'when updates #expected and #pending as true' do

          let(:params) { { properties: [{ id: property_id, expected: 'on', pending: true }] } }
          before       { update }
          subject      { resource.reload.properties.first }

          its(:pending)  { should == true }
          its(:value)    { should == 'on' }
          its(:expected) { should == 'on' }
        end

        describe 'when updates #value, #expected and #pending as false' do

          let(:params) { { properties: [{ id: property_id, value: 'on', expected: 'off', pending: false }] } }
          before       { update }
          subject      { resource.reload.properties.first }

          its(:pending)  { should == false }
          its(:value)    { should == 'on' }
          its(:expected) { should == 'on' }
        end
      end
    end
  end
end
