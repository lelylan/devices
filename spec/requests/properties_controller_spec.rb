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
    let(:properties) { [ { uri: a_uri(status), value: 'updated' }, { uri: a_uri(intensity), value: '20' } ] }
    let(:params)     { { pending: true, properties: properties } }
    let(:update)     { page.driver.put uri, params.to_json }

    let(:uri) { "/devices/#{resource.id}/properties" }

    it_behaves_like 'an updatable resource'
    it_behaves_like 'a not owned resource', 'page.driver.put(uri)'
    it_behaves_like 'a not found resource', 'page.driver.put(uri)'
    it_behaves_like 'a filterable resource', 'page.driver.put(uri)'
    it_behaves_like 'a registered event', 'page.driver.put(uri, params.to_json)'
    it_behaves_like 'a physical event', 'properties'
    it_behaves_like 'a signed resource'

    it 'touches the device' do
      resource.update_attributes(updated_at: Time.now - 60)
      expect { update }.to change { resource.reload.updated_at.to_i }
    end

    it 'creates a history resource' do
      expect { update }.to change { History.count }.by(1)
    end

    describe 'when creates an event' do

      before  { update }
      subject { Hashie::Mash.new Event.last.data['properties'].first }

      it 'has two properties' do
        Event.last.data['properties'].should have(2).properties
      end

      its(:id)    { should == status.id.to_s }
      its(:uri)   { should == properties.first[:uri] }
      its(:value) { should == properties.first[:value] }
    end

    describe 'when updates a not existing property' do

      let(:another) { FactoryGirl.create :property }
      let(:params)  { { properties: [ { uri: a_uri(another), value: 'not-valid' } ] } }

      it 'raises a not found property' do
        page.driver.put(uri, params.to_json)
        has_not_found_resource uri: params[:properties].map {|p| p[:uri]}, code: 'notifications.property.not_found'
      end

      it 'does not create an history resource' do
        expect { update }.to_not change { History.count }.by(1)
      end

      it 'does not create an event resource' do
        expect { update }.to_not change { Event.count }.by(1)
      end
    end

    describe '#physical' do

      describe 'when not connected' do

        before { update }

        it 'returns status code 200' do
          page.status_code.should == 200
        end
      end

      describe 'when connected' do

        let(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }

        before { update }

        it 'returns status code 202' do
          page.status_code.should == 202
        end
      end
    end
  end
end
