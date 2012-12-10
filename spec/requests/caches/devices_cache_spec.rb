require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature 'Caching' do

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

    describe 'with fragment caching' do

      it 'creates the fragment cache' do
        Rails.cache.exist?(cache_key).should be_true
      end

      it 'saves the JSON resource into the cache' do
        cached = JSON.parse Rails.cache.read(cache_key)
        has_resource resource, cached
      end
    end

    describe 'with HTTP caching' do

      describe 'when sends the If-Modified-Since header' do

        describe 'when the resource does not change' do

          before { page.driver.header 'If-Modified-Since', resource.updated_at.httpdate }
          before { page.driver.get uri }

          it 'returns a not modified response' do
            page.status_code.should == 304
          end
        end

        describe 'when the resource changes' do

          let!(:timestamp) { resource.updated_at }

          before { resource.updated_at = resource.updated_at + 1; resource.save }
          before { page.driver.header 'If-Modified-Since', (timestamp).httpdate }
          before { page.driver.get uri }

          it 'executes the action' do
            page.status_code.should == 200
          end

          it 'creates a new fragment cache' do
            new_key = ActiveSupport::Cache.expand_cache_key(['device_serializer', resource.cache_key, 'to-json'])
            Rails.cache.exist?(new_key).should be_true
          end

          it 'returns the Last-Modified header' do
            page.response_headers['Last-Modified'].should == resource.updated_at.httpdate
          end
        end
      end

      describe 'when sends the If-None-Match header' do

        let(:etag) { page.response_headers['ETag'] }

        describe 'when the resource does not change' do

          before { page.driver.header 'If-None-Match', etag }
          before { page.driver.get uri }

          it 'returns a not modified response' do
            page.status_code.should == 304
          end
        end

        describe 'when the resource changes' do

          before { resource.updated_at = resource.updated_at + 1; resource.save }
          before { page.driver.header 'If-None-Match', etag }
          before { page.driver.get uri }

          it 'executes the action' do
            page.status_code.should == 200
          end

          it 'creates a new fragment cache' do
            new_key = ActiveSupport::Cache.expand_cache_key(['device_serializer', resource.cache_key, 'to-json'])
            Rails.cache.exist?(new_key).should be_true
          end

          it 'returns the ETag header' do
            page.response_headers['ETag'].should_not == etag
          end
        end
      end
    end
  end

  # TODO: does not work with serializers
  #describe 'GET /devices/:id/privates' do
end
