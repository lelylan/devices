require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'ConnectionsController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'devices' }
  let(:factory)    { 'device' }

  context 'POST /devices/:id/connection' do

    let(:resource) { FactoryGirl.create 'device', resource_owner_id: user.id }
    let(:uri)      { "/devices/#{resource.id}/connection" }

    describe 'when generates the access token' do

      before { stub_request(:post, 'http://ws.lelylan.com/physicals') }

      it 'creates the access token' do
        expect { page.driver.post uri }.to change { Doorkeeper::AccessToken.count }.by(1)
      end

      describe 'when showing the access token' do
        before  { page.driver.post uri }
        subject { Doorkeeper::AccessToken.last }

        its(:scopes)     { should == Doorkeeper::OAuth::Scopes.from_string('devices') }
        its(:expires_in) { should == nil }
        its(:device_ids) { should == [resource.id] }
      end

      describe 'with previous access tokens' do

        let!(:physical_app) { Defaults.find_or_create_phisical_application }
        let!(:previous_access_token) { FactoryGirl.create :access_token, application: physical_app, scopes: 'devices', device_ids: [resource.id], resource_owner_id: user.id }

        it 'destroys previous access tokens related to the physical' do
          page.driver.post uri
          Doorkeeper::AccessToken.where(_id: previous_access_token.id).first.should == nil
        end

        describe 'with previous access tokens assigned to different physical devices' do

          let!(:another_resource)     { FactoryGirl.create 'device', resource_owner_id: user.id }
          let!(:another_access_token) { FactoryGirl.create :access_token, application: physical_app, scopes: 'devices', device_ids: [another_resource.id], resource_owner_id: user.id }

          it 'destroys only previous access tokens related to the physical' do
            expect { page.driver.post uri }.to change { Doorkeeper::AccessToken.count }.by(0)
          end
        end

        describe 'with access tokens assigned to different applications' do

          let!(:another_application)  { FactoryGirl.create :application }
          let!(:another_access_token) { FactoryGirl.create :access_token, application: another_application, scopes: 'devices', device_ids: [resource.id], resource_owner_id: user.id }

          it 'destroys only previous access tokens related to the physical app' do
            expect { page.driver.post uri }.to change { Doorkeeper::AccessToken.count }.by(0)
          end
        end
      end
    end

    describe 'when connects to the physical device' do

      describe 'when the response status is 200' do

        before { stub_request(:post, 'http://ws.lelylan.com/physicals') }
        before { page.driver.post uri }

        it 'sends the request' do
          a_request(:post, 'http://ws.lelylan.com/physicals').should have_been_made
        end

        it 'shows the device representation' do
          has_resource resource
        end
      end

      describe 'when the response status is not 200' do

        before { stub_request(:post, 'http://ws.lelylan.com/physicals').to_return(status: 500) }
        before { page.driver.post uri }

        it 'sends the request' do
          a_request(:post, 'http://ws.lelylan.com/physicals').should have_been_made
        end

        it 'shows the device representation' do
          page.status_code.should == 422
          page.should have_content 'notifications.physical.failed'
          page.should have_content 'Physical device access failed'
          #page.should have_content "#{resource.physical.uri}/physicals"
        end
      end
    end

    describe 'with no physical cannection' do

      let(:resource) { FactoryGirl.create 'device', :with_no_physical, resource_owner_id: user.id }

      it 'does not create the token' do
        page.driver.post uri
        page.status_code.should == 422
        page.should have_content 'notifications.physical.missing'
        page.should have_content 'Missing physical device connection'
      end
    end
  end
end
