require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature DailyRateLimit do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user, rate_limit: 5000 }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'devices' }
  let(:factory)    { 'device' }

  describe 'when request header contains an authorization token' do

    before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

    let!(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }
    let(:uri)       { "/devices/#{resource.id}" }

    before { page.driver.get uri }

    it 'sets the rate limit header' do
      page.response_headers['X-RateLimit-Limit'].should == '5000'
    end

    it 'sets the remaining requests header' do
      page.response_headers['X-RateLimit-Remaining'].should == '4999'
    end

    describe 'when the same user makes a request' do

      before { page.driver.get uri }

      it 'lowers the request rate' do
        page.response_headers['X-RateLimit-Remaining'].should == '4998'
      end
    end

    describe 'when another user makes a request' do

      let!(:another_user)         { FactoryGirl.create :user, rate_limit: 5000 }
      let!(:another_access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: another_user.id }

      before { page.driver.header 'Authorization', "Bearer #{another_access_token.token}" }
      before { page.driver.get uri }

      it 'sets the higher request rate' do
        page.response_headers['X-RateLimit-Remaining'].should == '4999'
      end
    end
  end

  describe 'when request header contains a not existing authorization token' do

    before { page.driver.header 'Authorization', "Bearer #{access_token.token}-not-existing" }

    let!(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }
    let(:uri)       { "/devices/#{resource.id}" }

    before { page.driver.get uri }

    it 'does not set the rate limit header' do
      page.response_headers['X-RateLimit-Limit'].should == '9999'
    end

    it 'returns a not authorized code' do
      page.status_code.should == 401
    end
  end

  describe 'when request header does not contain an authorization token' do

    let!(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }
    let(:uri)       { "/devices/#{resource.id}" }

    before { page.driver.get uri }

    it 'does not set the rate limit header' do
      page.response_headers['X-RateLimit-Limit'].should == nil
    end

    it 'does not set the rate remaining requests header' do
      page.response_headers['X-RateLimit-Remaining'].should == nil
    end
  end

  describe 'when the user has higher late limit' do

    before { user.update_attributes(rate_limit: 25000) }
    before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

    let!(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }
    let(:uri)       { "/devices/#{resource.id}" }

    before { page.driver.get uri }

    it 'sets the higher rate limit header (pro user)' do
      page.response_headers['X-RateLimit-Limit'].should == '25000'
    end

    it 'sets the higher remaining requests header (pro user)' do
      page.response_headers['X-RateLimit-Remaining'].should == '24999'
    end
  end

  describe 'when the user reach the rate limit' do

    before { user.update_attributes(rate_limit: 0) }
    before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

    let!(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }
    let(:uri)       { "/devices/#{resource.id}" }

    before { page.driver.get uri }

    it 'returns a 403 status code' do
      page.status_code.should == 403
    end

    describe 'when returns the body' do

      describe 'with the meta information' do

        subject { Hashie::Mash.new JSON.parse(page.source) }

        its(:status) { should == 403 }
        its(:request) { should == page.current_url }
      end

      describe 'with the error information' do

        subject { Hashie::Mash.new JSON.parse(page.source)['error'] }

        its(:code) { should == 'notifications.access.rate_limit' }
        its(:description) { should == 'Rate limit exceeded' }
        its(:daily_rate_limit) { should == 0 }
      end
    end
  end
end
