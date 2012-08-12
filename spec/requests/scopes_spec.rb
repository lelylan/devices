require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'Scope' do

  let!(:application) { FactoryGirl.create :application }
  let!(:user)        { FactoryGirl.create :user }

  context 'with read scope' do

    let!(:scopes)       { 'read' }
    let!(:access_token) { FactoryGirl.create :access_token, scopes: scopes, resource_owner_id: user.id }

    before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

    context 'devices controller' do

      let(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }

      it { should authorize 'get /devices' }
      it { should authorize "get /devices/#{resource.id}" }

      it { should_not authorize 'post /devices' }
      it { should_not authorize "put /devices/#{resource.id}" }
      it { should_not authorize "delete /devices/#{resource.id}" }
    end

    context 'properties controller' do

      let(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }

      it { should_not authorize "put /devices/#{resource.id}/properties" }
    end

    context 'functions controller' do

      let(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }

      it { should_not authorize "put /devices/#{resource.id}/functions" }
    end

    context 'physicals controller' do

      let(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }

      it { should_not authorize "put /devices/#{resource.id}/physical" }
      it { should_not authorize "delete /devices/#{resource.id}/physical" }
    end

    context 'histories controller' do

      let(:resource) { FactoryGirl.create :history, resource_owner_id: user.id }

      it { should authorize 'get /histories' }
      it { should authorize "get /histories/#{resource.id}" }
    end

    context 'consumptions controller' do

      let(:resource) { FactoryGirl.create :consumption, resource_owner_id: user.id }

      it { should authorize 'get /consumptions' }
      it { should authorize "get /consumptions/#{resource.id}" }

      it { should_not authorize 'post /consumptions' }
      it { should_not authorize "put /consumptions/#{resource.id}" }
      it { should_not authorize "delete /consumptions/#{resource.id}" }
    end
  end

  context 'with write scope' do

    let!(:scopes)       { 'write' }
    let!(:access_token) { FactoryGirl.create :access_token, scopes: scopes, resource_owner_id: user.id }

    before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

    context 'devices controller' do

      let(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }

      it { should authorize 'get /devices' }
      it { should authorize "get /devices/#{resource.id}" }
      it { should authorize 'post /devices' }
      it { should authorize "put /devices/#{resource.id}" }
      it { should authorize "delete /devices/#{resource.id}" }
    end

    context 'properties controller' do

      let(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }

      it { should authorize "put /devices/#{resource.id}/properties" }
    end

    context 'functions controller' do

      let(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }

      it { should authorize "put /devices/#{resource.id}/functions?uri=http://lely.me/xy1" }
    end

    context 'physicals controller' do

      let(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }

      it { should authorize "put /devices/#{resource.id}/physical" }
      it { should authorize "delete /devices/#{resource.id}/physical" }
    end

    context 'histories controller' do

      let(:resource) { FactoryGirl.create :history, resource_owner_id: user.id }

      it { should authorize 'get /histories' }
      it { should authorize "get /histories/#{resource.id}" }
    end

    context 'consumptions controller' do

      let(:resource) { FactoryGirl.create :consumption, resource_owner_id: user.id }

      it { should authorize 'get /consumptions' }
      it { should authorize "get /consumptions/#{resource.id}" }

      it { should authorize 'post /consumptions' }
      it { should authorize "put /consumptions/#{resource.id}" }
      it { should authorize "delete /consumptions/#{resource.id}" }
    end
  end
end
