require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature 'Caching' do

  before { ActionController::Base.perform_caching = true }
  before { Rails.cache.clear }
  after  { ActionController::Base.perform_caching = false }

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-location', 'application/json' }

  let(:controller) { 'locations' }
  let(:factory)    { 'location' }

  describe 'when a location contains a device' do

    let!(:resource) { FactoryGirl.create :location, :with_devices, resource_owner_id: user.id }
    let!(:device)   { Device.find(resource.device_ids).first }
    before          { resource.update_attributes(updated_at: Time.now - 60) }
    let!(:uri)      { "/devices/#{device.id}" }
    let!(:old_time) { resource.updated_at }

    describe 'when the device is updated' do

      describe 'with a new name' do

        let!(:connection) { device.update_attributes(name: 'updated') }
        let!(:new_time)   { resource.reload.updated_at }

        it 'updates the location updated_at attribute' do
          (new_time - old_time).should be_within(1).of(60)
        end
      end

      describe 'with anything but a new name' do

        let!(:connection) { device.save }
        let!(:new_time)   { resource.reload.updated_at }

        it 'does not update the location updated_at attribute' do
          (new_time - old_time).should be_within(1).of(0)
        end
      end
    end
  end
end

