require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'PhysicalsController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'devices' }
  let(:factory)    { 'device' }

  context 'PUT /devices/:id/physical' do

    let!(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }
    let(:uri)       { "/devices/#{resource.id}/physical" }
    let(:params)    { { physical: { uri: "https://mqtt.lelylan.com/physicals/updated" } } }

    it_behaves_like 'an updatable resource'
    it_behaves_like 'a not owned resource', 'page.driver.put(uri)'
    it_behaves_like 'a not found resource', 'page.driver.put(uri)'
    it_behaves_like 'a validated resource', 'page.driver.put(uri, { name: "" }.to_json)', { method: 'PUT', error: 'can\'t be blank' }
  end

  context 'DELETE /devices/:id/physical' do
    let!(:resource)  { FactoryGirl.create :device, resource_owner_id: user.id }
    let!(:old_uri)   { resource.physical.uri }
    let(:uri)        { "/devices/#{resource.id}/physical" }

    it 'has not the physical device' do
      page.driver.delete(uri)
      page.should_not have_content old_uri
      resource.reload.physical.should be_nil
    end

    it_behaves_like 'a not owned resource', 'page.driver.delete(uri)'
    it_behaves_like 'a not found resource', 'page.driver.delete(uri)'
  end
end
