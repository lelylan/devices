require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'FunctionsController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'devices' }
  let(:factory)    { 'device' }

  context 'PUT /devices/:id/functions' do

    let(:resource)  { FactoryGirl.create :device, :with_no_physical, resource_owner_id: user.id }
    let(:status)    { Property.find resource.properties.first.id }
    let(:intensity) { Property.find resource.properties.last.id }

    let(:function_properties) { [ { id: status.id, value: 'on' }, { id: intensity.id } ] }
    let(:function) { FactoryGirl.create :function, properties: function_properties }

    let(:properties) { [ { id: intensity.id, value: 'updated' } ] }
    let(:params)     { { properties: properties, function: { id: function.id } } }
    let(:update)     { page.driver.put uri, params.to_json }

    let(:uri) { "/devices/#{resource.id}/functions" }

    it_behaves_like 'an updatable resource'
    it_behaves_like 'an updatable resource from physical'
    it_behaves_like 'a sourceable resource'
    it_behaves_like 'a forwardable physical request resource'
    it_behaves_like 'a functionable resource'
    it_behaves_like 'a not owned resource', 'page.driver.put(uri)'
    it_behaves_like 'a not found resource', 'page.driver.put(uri)'
    it_behaves_like 'a filterable resource', 'page.driver.put(uri)'
    it_behaves_like 'a registered event', 'page.driver.put(uri, params.to_json)', nil, 'devices', 'property-update'

    # temporary disabled
    # it_behaves_like 'a historable resource'

    it 'touches the device' do
      resource.updated_at = Time.now - 60; resource.save
      expect { update }.to change { resource.reload.updated_at.to_i }
    end

    describe 'when creates an event' do

      before  { update }

      it 'has two properties' do
        Event.last.data['properties'].should have(2).properties
      end

      describe 'with a property defined in the function' do

        subject { Hashie::Mash.new Event.last.data['properties'].first }

        its(:id)    { should == status.id.to_s }
        its(:uri)   { should match(status.id.to_s) }
        its(:value) { should == 'on' }
      end

      describe 'with a property defined in the body request' do

        subject { Hashie::Mash.new Event.last.data['properties'].last }

        its(:id)    { should == intensity.id.to_s }
        its(:uri)   { should match(intensity.id.to_s) }
        its(:value) { should == 'updated' }
      end
    end

    describe 'when updates a not existing property' do

      let(:another) { FactoryGirl.create :property }
      let(:params)  { { properties: [ { id: another.id, value: 'not-valid' } ], function: { id: function.id } } }

      it 'raises a not found property' do
        page.driver.put(uri, params.to_json)
        has_not_found_resource uri: params[:properties].map {|p| p[:uri]}, code: 'notifications.property.not_found'
      end

      # temporary disabled
      #it 'does not create an history resource' do
        #expect { update }.to_not change { History.count }.by(1)
      #end

      it 'does not create an event resource' do
        expect { update }.to_not change { Event.count }.by(1)
      end
    end
  end
end
