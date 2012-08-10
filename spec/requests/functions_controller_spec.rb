require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'FunctionsController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'write', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'devices' }
  let(:factory)    { 'device' }

  context 'PUT /devices/:id/functions' do

    let(:resource)  { FactoryGirl.create :device, resource_owner_id: user.id }
    let(:status)    { Property.find resource.properties.first.id }
    let(:intensity) { Property.find resource.properties.last.id }

    let(:properties)   { [ { uri: a_uri(status), value: 'on' }, { uri: a_uri(intensity) } ] }
    let(:function)     { FactoryGirl.create :function, properties: properties }
    let(:function_uri) { a_uri function }

    let(:params)    { { properties: [{ uri: a_uri(intensity), value: 'updated' } ] } }

    let(:uri) { "/devices/#{resource.id}/functions?uri=#{function_uri}" }

    it 'should create an history resource' do
      expect { page.driver.put(uri) }.to change { History.count }.by(1)
    end

    it_behaves_like 'an updatable resource'
    it_behaves_like 'a not owned resource', 'page.driver.put(uri)'
    it_behaves_like 'a not found resource', 'page.driver.put(uri)'

    # TODO add a system to validate the structure of sent data
  end
end
