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

    it 'generates an access token' do
      expect { page.driver.post uri }.to change { Doorkeeper::AccessToken.count }.by(1)
    end

    describe 'when generates the access token' do

      before  { page.driver.post uri }
      subject { Doorkeeper::AccessToken.last }

      its(:scopes)     { should == Doorkeeper::OAuth::Scopes.from_string('devices') }
      its(:expires_in) { should == nil }
      its(:device_ids) { should == [resource.id] }
    end

    describe 'with finds previously generated access tokens for the physical device' do

      let!(:physical_app) { Defaults.find_or_create_phisical_application }
      let!(:previous_access_token) { FactoryGirl.create :access_token, application: physical_app, scopes: 'devices', device_ids: [resource.id], resource_owner_id: user.id }

      it 'removes previous access tokens' do
        page.driver.post uri
        Doorkeeper::AccessToken.where(_id: previous_access_token.id).first.should == nil
      end

      describe 'when there are access tokens assigned to different physical devices' do

        let!(:another_resource)     { FactoryGirl.create 'device', resource_owner_id: user.id }
        let!(:another_access_token) { FactoryGirl.create :access_token, application: physical_app, scopes: 'devices', device_ids: [another_resource.id], resource_owner_id: user.id }

        it 'does destroy only the device related tokens' do
          expect { page.driver.post uri }.to change { Doorkeeper::AccessToken.count }.by(0)
        end
      end

      describe 'when there are access tokens assigned to different applications' do

        let!(:another_application)  { FactoryGirl.create :application }
        let!(:another_access_token) { FactoryGirl.create :access_token, application: another_application, scopes: 'devices', device_ids: [resource.id], resource_owner_id: user.id }

        it 'does destroy only the device related tokens' do
          expect { page.driver.post uri }.to change { Doorkeeper::AccessToken.count }.by(0)
        end
      end
    end
  end
end
