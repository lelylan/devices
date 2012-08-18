require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'DevicesController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'devices' }
  let(:factory)    { 'device' }

  describe 'GET /devices' do

    let!(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }
    let(:uri)       { '/devices' }

    it_behaves_like 'a listable resource'
    it_behaves_like 'a paginable resource'
    it_behaves_like 'a searchable resource', { name: 'My name is resource', pending: 'true', type: a_uri(FactoryGirl.create :type) }
    it_behaves_like 'a searchable resource on properties'

    describe 'with advanced scope' do

      describe 'when limits number of accessible devices' do

        let(:result) { FactoryGirl.create :device, resource_owner_id: user.id }

        before  { access_token.devices = [result.id]; access_token.save; }
        before  { page.driver.get uri }
        subject { page }

        it { should have_content result.id.to_s }
        it { should_not have_content resource.id.to_s }
      end
    end
  end

  context 'GET /devices/:id' do

    let!(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }
    let(:uri)       { "/devices/#{resource.id}" }

    it_behaves_like 'a showable resource'
    it_behaves_like 'a changeable host'
    it_behaves_like 'a not owned resource', 'page.driver.get(uri)'
    it_behaves_like 'a not found resource', 'page.driver.get(uri)'
  end

  context 'POST /devices' do

    let(:uri)    { '/devices' }
    let(:device) { FactoryGirl.create 'device' }
    let(:type)   { FactoryGirl.create 'type' }
    let(:params) { { name: 'Dimmer', type: a_uri(type) } }

    before         { page.driver.post uri, params.to_json }
    let(:resource) { Device.last }

    it_behaves_like 'a creatable resource'
    it_behaves_like 'a validated resource', 'page.driver.post(uri, {}.to_json)', { method: 'POST', error: 'can\'t be blank' }
  end

  context 'PUT /devices/:id' do

    let!(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }
    let(:uri)       { "/devices/#{resource.id}" }
    let(:params)    { { name: 'updated' } }

    it_behaves_like 'an updatable resource'
    it_behaves_like 'a not owned resource', 'page.driver.put(uri)'
    it_behaves_like 'a not found resource', 'page.driver.put(uri)'
    it_behaves_like 'a validated resource', 'page.driver.put(uri, { name: "" }.to_json)', { method: 'PUT', error: 'can\'t be blank' }
  end

  context 'DELETE /devices/:id' do
    let!(:resource)  { FactoryGirl.create :device, resource_owner_id: user.id }
    let(:uri)        { "/devices/#{resource.id}" }

    it_behaves_like 'a deletable resource'
    it_behaves_like 'a not owned resource', 'page.driver.delete(uri)'
    it_behaves_like 'a not found resource', 'page.driver.delete(uri)'
  end
end
