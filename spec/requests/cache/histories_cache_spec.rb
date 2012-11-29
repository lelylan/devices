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

  let(:controller) { 'histories' }
  let(:factory)    { 'history' }

  describe 'GET /histories/:id' do

    let!(:resource) { FactoryGirl.create :history, resource_owner_id: user.id }
    let(:uri)       { "/histories/#{resource.id}" }
    let(:cache_key) { ActiveSupport::Cache.expand_cache_key(['history_serializer', resource.cache_key, 'to-json']) }

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

        # the resource does not change so once it is cached its done
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

        # the resource does not change so once it is cached its done
      end
    end
  end
end
