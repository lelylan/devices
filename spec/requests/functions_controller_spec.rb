require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'FunctionsController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'devices' }
  let(:factory)    { 'device' }

  context 'PUT /devices/:id/functions' do

    let(:resource)  { FactoryGirl.create :device, :with_no_physical, resource_owner_id: user.id }
    let(:status)    { Property.find resource.properties.first.id }
    let(:intensity) { Property.find resource.properties.last.id }

    let(:properties)   { [ { uri: a_uri(status), value: 'on' }, { uri: a_uri(intensity) } ] }
    let(:function)     { FactoryGirl.create :function, properties: properties }
    let(:function_uri) { a_uri function }

    let(:properties) { [ { uri: a_uri(intensity), value: 'updated' } ] }
    let(:params) { { pending: true, properties: properties, function: function_uri } }
    let(:update) { page.driver.put uri, params.to_json }

    let(:uri) { "/devices/#{resource.id}/functions" }

    it_behaves_like 'an updatable resource'
    it_behaves_like 'a not owned resource', 'page.driver.put(uri)'
    it_behaves_like 'a not found resource', 'page.driver.put(uri)'
    it_behaves_like 'a filterable resource', 'page.driver.put(uri)'
    it_behaves_like 'a registered event', 'page.driver.put(uri, params.to_json)'

    it 'creates an history resource' do
      expect { update }.to change { History.count }.by(1)
    end

    it 'creates an history resource' do
      expect { update }.to change { resource.reload.pending }.from(false).to(true)
    end

    it 'updates #updated_at' do
      old = Time.now - 60
      resource.update_attributes(updated_at: old)
      expect { update }.to change { resource.reload.updated_at.to_i }
    end

    context 'with a not existing property' do

      let(:another) { FactoryGirl.create :property }
      let(:params)  { { properties: [ { uri: a_uri(another), value: 'not-valid' } ], function: function_uri } }

      it 'raises a not found property' do
        page.driver.put(uri, params.to_json)
        has_not_found_resource uri: params[:properties].map {|p| p[:uri]}
      end

      it 'does not create an history resource' do
        expect { update }.to_not change { History.count }.by(1)
      end
    end

    context 'with no physical connection' do

      before { update }

      it 'returns status code OK' do
        page.status_code.should == 200
      end
    end

    context 'with physical connection' do

      let(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }

      before { update }

      it 'returns status code Accepted' do
        page.status_code.should == 202
      end
    end
  end
end
