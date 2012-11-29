require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../../app/serializers/device_serializer')

feature 'Fragment Caching' do

  before { ActionController::Base.perform_caching = true }
  before { Rails.cache.clear }
  after  { ActionController::Base.perform_caching = false }

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'devices' }
  let(:factory)    { 'device' }

  describe 'GET /devices/:id' do

    let!(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }
    let(:uri)       { "/devices/#{resource.id}" }
    let(:cache_key) { ActiveSupport::Cache.expand_cache_key(['device_serializer', resource.cache_key, 'to-json']) }

    before { page.driver.get uri }

    it 'creates the fragment cache' do
      Rails.cache.exist?(cache_key).should be_true
    end

    it 'save the json resource' do
      cached = JSON.parse Rails.cache.read(cache_key)
      has_resource resource, cached
    end
  end
end

#describe 'when If-Modified-Since match with the resource updated at' do

        #before { page.driver.header 'If-Modified-Since', resource.updated_at.httpdate }


