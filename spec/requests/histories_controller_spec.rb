require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'HistorysController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'write', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'histories' }
  let(:factory)    { 'history' }

  describe 'GET /histories' do

    let!(:resource)  { FactoryGirl.create :history, resource_owner_id: user.id }
    let(:uri)        { '/histories' }

    #it_behaves_like 'a listable resource'
    #it_behaves_like 'a paginable resource'

    context 'when searches properties' do

      let!(:result) { FactoryGirl.create :history, resource_owner_id: user.id }

      #context 'when filters the property uri' do

        #let(:property_uri) { a_uri(result.properties.first, :property_id) }

        #it 'returns the searched resource' do
          #page.driver.get uri, property: property_uri
          #contains_resource result
          #page.should_not have_content resource.id.to_s
        #end
      #end

      #context 'when filters the property value' do

        #before { result.properties.first.update_attributes(value: 'updated') }

        #it 'returns the searched resource' do
          #page.driver.get uri, value: 'updated'
          #contains_resource result
          #page.should_not have_content resource.id.to_s
        #end
      #end

      context 'when filters the property uri and property value' do

        let(:property_uri) { a_uri(result.properties.first, :property_id) }
        before             { result.properties.first.update_attributes(value: 'updated') }

        it 'returns the searched resource' do
          page.driver.get uri, property: property_uri, value: 'updated'
          contains_resource result
          page.should_not have_content resource.id.to_s
        end
      end
    end

        #context "property_value" do
          #before { @property_value = Settings.properties.another.value }
          #before { @result = FactoryGirl.create(:device) }
          #before { @result.device_properties.first.update_attributes(value: @property_value) }

          #it "should filter the searched value" do
            #visit "#{@uri}?property_value=#{@property_value}"
            #should_contain_device @result
            #page.should_not have_content @resource.device_properties.first.value
          #end
        #end

        ## Property uri and property value belong to the same embedded property
        ## In this case the search does match with a property
        #context "property_uri and property_value" do
          #before { @result = FactoryGirl.create(:device) }
          #before { @property_uri = Settings.properties.another.uri }
          #before { @property_value = Settings.properties.another.value }
          #before { @result.device_properties.first.update_attributes(uri: @property_uri) }
          #before { @result.device_properties.first.update_attributes(value: @property_value) }

          #it "should filter the searched value" do
            #visit "#{@uri}?property_uri=#{@property_uri}&property_value=#{@property_value}"
            #should_contain_device @result
            #page.should_not have_content @resource.device_properties.first.uri
            #page.should_not have_content @resource.device_properties.first.value
          #end
        #end

        ## Property uri and property value belong to two different embedded properties.
        ## In this case the search does not match with any property.
        #context "property_uri and property_value for different properties" do
          #before { @property_uri = Settings.properties.another.uri }
          #before { @property_value = Settings.properties.another.value }
          #before { @result = FactoryGirl.create(:device) }
          #before { @result.device_properties.first.update_attributes(uri: @property_uri) }
          #before { @result.device_properties.first.update_attributes(value: @property_value) }

          #it "should filter the searched value" do
            #visit "#{@uri}?property_uri=#{Settings.properties.intensity.uri}&property_value=#{@property_value}"
            #JSON.parse(page.source).should be_empty
          #end
        #end

    # TODO add tests based on time search (a shared example where you pass the start and end field names is fine as it is a common feature)
    # TODO think also about creating a concern for it
  end

  #context 'GET /histories/:id' do

    #let!(:resource) { FactoryGirl.create :history, resource_owner_id: user.id }
    #let(:uri)       { "/histories/#{resource.id}" }

    #context 'when shows the owned durational history' do
      #before { page.driver.get uri }
      #it     { has_resource resource }
    #end

    #context 'when shows the owned instantaneous history' do
      #let!(:resource) { FactoryGirl.create :history, resource_owner_id: user.id }

      #before { page.driver.get uri }
      #it     { has_resource resource }
    #end

    #it_behaves_like 'a changeable host'
    #it_behaves_like 'a not owned resource', 'page.driver.get(uri)'
    #it_behaves_like 'a not found resource', 'page.driver.get(uri)'
  #end
end
