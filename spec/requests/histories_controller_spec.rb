require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'HistorysController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'histories' }
  let(:factory)    { 'history' }

  describe 'GET /histories' do

    let!(:resource)  { FactoryGirl.create :history, resource_owner_id: user.id }
    let(:uri)        { '/histories' }

    it_behaves_like 'a listable resource'
    it_behaves_like 'a paginable resource'
    it_behaves_like 'a searchable resource', { device: a_uri(FactoryGirl.create :device), source: 'physical' }
    it_behaves_like 'a searchable resource on properties'
    it_behaves_like 'a searchable resource on timing', 'created_at'
    it_behaves_like 'a filterable list'
  end

  context 'GET /histories/:id' do

    let!(:resource) { FactoryGirl.create :history, resource_owner_id: user.id }
    let(:uri)       { "/histories/#{resource.id}" }

    it_behaves_like 'a showable resource'
    it_behaves_like 'a proxiable resource'
    it_behaves_like 'a crossable resource'
    it_behaves_like 'a not owned resource', 'page.driver.get(uri)'
    it_behaves_like 'a not found resource', 'page.driver.get(uri)'
    it_behaves_like 'a filterable resource', 'page.driver.get(uri)'
  end
end
