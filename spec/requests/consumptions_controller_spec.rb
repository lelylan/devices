require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'ConsumptionsController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'write', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'consumptions' }
  let(:factory)    { 'consumption' }

  describe 'GET /consumptions' do

    let!(:resource)  { FactoryGirl.create :consumption, :durational, resource_owner_id: user.id }
    let(:uri)        { '/consumptions' }

    it_behaves_like 'a listable resource'
    it_behaves_like 'a paginable resource'
    it_behaves_like 'a searchable resource', { type: 'instantaneous', unit: 'lives', device: a_uri(FactoryGirl.create :device) }

    # TODO add tests based on time search (a shared example where you pass the start and end field names is fine as it is a common feature)
  end

  context 'GET /consumptions/:id' do

    let!(:resource) { FactoryGirl.create :consumption, :durational, resource_owner_id: user.id }
    let(:uri)       { "/consumptions/#{resource.id}" }

    context 'when shows the owned durational consumption' do
      before { page.driver.get uri }
      it     { has_resource resource }
    end

    context 'when shows the owned instantaneous consumption' do
      let!(:resource) { FactoryGirl.create :consumption, resource_owner_id: user.id }

      before { page.driver.get uri }
      it     { has_resource resource }
    end

    it_behaves_like 'a changeable host'
    it_behaves_like 'a not owned resource', 'page.driver.get(uri)'
    it_behaves_like 'a not found resource', 'page.driver.get(uri)'
  end

  context 'POST /consumptions' do

    let(:uri)    { '/consumptions' }
    let(:device) { FactoryGirl.create 'device' }
    let(:params) {{ 
      name:     'Set intensity',
      device:   a_uri(device),
      type:     'durational',
      value:    '0.01',
      unit:     'kwh',
      occur_at: Time.now,
      duration: 60
    }}

    before         { page.driver.post uri, params.to_json }
    let(:resource) { Consumption.last }

    it_behaves_like 'a creatable resource'
    it_behaves_like 'a validated resource', 'page.driver.post(uri, {}.to_json)', { method: 'POST', error: 'can\'t be blank' }
  end

  context 'PUT /consumptions/:id' do

    let!(:resource) { FactoryGirl.create :consumption, resource_owner_id: user.id }
    let(:uri)       { "/consumptions/#{resource.id}" }
    let(:params)    { { value: 'updated' } }

    it_behaves_like 'an updatable resource'
    it_behaves_like 'a not owned resource', 'page.driver.put(uri)'
    it_behaves_like 'a not found resource', 'page.driver.put(uri)'
    it_behaves_like 'a validated resource', 'page.driver.put(uri, { type: "" }.to_json)', { method: 'PUT', error: 'is not included in the list' }
  end

  context 'DELETE /consumptions/:id' do
    let!(:resource)  { FactoryGirl.create :consumption, resource_owner_id: user.id }
    let(:uri)        { "/consumptions/#{resource.id}" }

    it_behaves_like 'a deletable resource'
    it_behaves_like 'a not owned resource', 'page.driver.delete(uri)'
    it_behaves_like 'a not found resource', 'page.driver.delete(uri)'
  end
end
