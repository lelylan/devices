require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'PropertiesController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'write', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'devices' }
  let(:factory)    { 'device' }

  context 'PUT /devices/:id/properties' do

    let(:resource)  { FactoryGirl.create :device, resource_owner_id: user.id }
    let(:status)    { Property.find resource.properties.first.id }
    let(:intensity) { Property.find resource.properties.last.id }
    let(:params)    { { properties: [ { uri: a_uri(status), value: 'updated' }, { uri: a_uri(intensity), value: '20' } ] } }

    let(:uri) { "/devices/#{resource.id}/properties" }

    it 'creates an history resource' do
      expect { page.driver.put(uri) }.to change { History.count }.by(1)
    end

    context 'with not existing property' do

      let(:another) { FactoryGirl.create :property }
      let(:params)  { { properties: [ { uri: a_uri(another), value: 'updated' } ] } }

      it 'raises a not found connection' do
        page.driver.put(uri, params.to_json)
        has_not_found_resource uri: params[:properties].map {|p| p[:uri]}
        save_and_open_page
      end
    end

    it_behaves_like 'an updatable resource'
    it_behaves_like 'a not owned resource', 'page.driver.put(uri)'
    it_behaves_like 'a not found resource', 'page.driver.put(uri)'

    # TODO add a system to validate the structure of sent data
  end
end
