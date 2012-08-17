require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'Scope' do

  let!(:application) { FactoryGirl.create :application }
  let!(:user)        { FactoryGirl.create :user }

  %w(devices.read resources.read).each do |scope|

    context "with scope #{scope}" do

      let!(:access_token) { FactoryGirl.create :access_token, scopes: scope, resource_owner_id: user.id }

      let(:device)      { FactoryGirl.create :device, resource_owner_id: user.id }
      let(:history)     { FactoryGirl.create :history, resource_owner_id: user.id }
      let(:consumption) { FactoryGirl.create :consumption, resource_owner_id: user.id }

      before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

      it { should authorize 'get /devices' }
      it { should authorize "get /devices/#{device.id}" }
      it { should authorize 'get /histories' }
      it { should authorize "get /histories/#{history.id}" }
      it { should authorize 'get /consumptions' }
      it { should authorize "get /consumptions/#{consumption.id}" }

      it { should_not authorize 'post   /devices' }
      it { should_not authorize "put    /devices/#{device.id}" }
      it { should_not authorize "delete /devices/#{device.id}" }
      it { should_not authorize "put    /devices/#{device.id}/properties" }
      it { should_not authorize "put    /devices/#{device.id}/functions" }
      it { should_not authorize "put    /devices/#{device.id}/physical" }
      it { should_not authorize "delete /devices/#{device.id}/physical" }
      it { should_not authorize 'post   /consumptions' }
      it { should_not authorize "put    /consumptions/#{consumption.id}" }
      it { should_not authorize "delete /consumptions/#{consumption.id}" }
    end
  end

  %w(devices resources).each do |scope|

    context "with scope #{scope}" do

      let!(:access_token) { FactoryGirl.create :access_token, scopes: scope, resource_owner_id: user.id }

      let(:device)      { FactoryGirl.create :device, resource_owner_id: user.id }
      let(:history)     { FactoryGirl.create :history, resource_owner_id: user.id }
      let(:consumption) { FactoryGirl.create :consumption, resource_owner_id: user.id }
      let(:function)    { FactoryGirl.create :function }

      before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }

      it { should authorize 'get    /devices' }
      it { should authorize "get    /devices/#{device.id}" }
      it { should authorize 'post   /devices' }
      it { should authorize "put    /devices/#{device.id}" }
      it { should authorize "delete /devices/#{device.id}" }
      it { should authorize "put    /devices/#{device.id}/properties" }
      it { should authorize "put    /devices/#{device.id}/functions?uri=#{a_uri(function)}" }
      it { should authorize "put    /devices/#{device.id}/physical" }
      it { should authorize "delete /devices/#{device.id}/physical" }
      it { should authorize 'get    /histories' }
      it { should authorize "get    /histories/#{history.id}" }
      it { should authorize 'get    /consumptions' }
      it { should authorize "get    /consumptions/#{consumption.id}" }
      it { should authorize 'post   /consumptions' }
      it { should authorize "put    /consumptions/#{consumption.id}" }
      it { should authorize "delete /consumptions/#{consumption.id}" }
    end
  end
end
