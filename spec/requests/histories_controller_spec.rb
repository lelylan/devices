require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'HistorysController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'write', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'histories' }
  let(:factory)    { 'history' }

  describe 'GET /histories' do

    let!(:resource)  { FactoryGirl.create :history, resource_owner_id: user.id }
    let(:uri)        { '/histories' }

    it_behaves_like 'a listable resource'
    it_behaves_like 'a paginable resource'
    it_behaves_like 'a searchable resource', { device: a_uri(FactoryGirl.create :device) }
    it_behaves_like 'a searchable resource on properties'

    # TODO add tests based on time search (a shared example where you pass the start and end field names is fine as it is a common feature)
    # TODO think also about creating a concern for it
  end

  context 'GET /histories/:id' do

    let!(:resource) { FactoryGirl.create :history, resource_owner_id: user.id }
    let(:uri)       { "/histories/#{resource.id}" }

    context 'when shows the owned durational history' do
      before { page.driver.get uri }
      it     { has_resource resource }
    end

    context 'when shows the owned instantaneous history' do
      let!(:resource) { FactoryGirl.create :history, resource_owner_id: user.id }

      before { page.driver.get uri }
      it     { has_resource resource }
    end

    it_behaves_like 'a changeable host'
    it_behaves_like 'a not owned resource', 'page.driver.get(uri)'
    it_behaves_like 'a not found resource', 'page.driver.get(uri)'
  end
end
