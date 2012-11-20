require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'ActivationsController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'devices' }
  let(:factory)    { 'device' }

  context 'POST /activations' do

    let(:uri)             { '/activations' }
    let(:another_user)    { FactoryGirl.create :user }
    let(:resource)        { FactoryGirl.create 'device', activated_at: nil, resource_owner_id: another_user.id }
    let(:activation_code) { Signature.sign resource.id, resource.secret }
    let!(:params)         { { activation_code: activation_code } }

    it 'can be activated by anyone' do
      expect { page.driver.post(uri, params.to_json) }.to_not change { Device.count }
      page.status_code.should == 201
      has_resource resource.reload
    end

    describe 'when the activation code does not exist' do

      let(:activation_code) { Signature.sign resource.id, 'not-existing' }

      it 'can not be activated by another user' do
        page.driver.post(uri, params.to_json)
        page.status_code.should == 404
        page.should have_content 'notifications.activation.not_found'
        page.should have_content 'Activation code not found'
      end
    end

    describe 'when the resource is already activated' do

      let(:resource) { FactoryGirl.create 'device', resource_owner_id: another_user.id }

      it 'can not be activated by another user' do
        page.driver.post(uri, params.to_json)
        page.status_code.should == 422
        page.should have_content 'notifications.resource.already_activated'
        page.should have_content 'Resource is already activated'
        page.should have_content resource.resource_owner_id.to_s
      end
    end
  end

  context 'DELETE /activations/:id' do

    let!(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }
    let(:uri)       { "/activations/#{resource.id}" }

    it 'deactivates the resource' do
      expect { page.driver.delete(uri) }.to_not change{ Device.count }
      page.driver.delete(uri)
      resource.reload.activated_at.should == nil
      page.status_code.should == 200
      has_resource resource
    end

    it_behaves_like 'a not owned resource', 'page.driver.delete(uri)'
    it_behaves_like 'a not found resource', 'page.driver.delete(uri)'
    it_behaves_like 'a filterable resource', 'page.driver.delete(uri)'
  end
end
