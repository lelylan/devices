require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature 'PropertiesController' do

  let!(:application)  { FactoryGirl.create :application }
  let!(:user)         { FactoryGirl.create :user }
  let!(:access_token) { FactoryGirl.create :access_token, application: application, scopes: 'resources', resource_owner_id: user.id }

  before { page.driver.header 'Authorization', "Bearer #{access_token.token}" }
  before { page.driver.header 'Content-Type', 'application/json' }

  let(:controller) { 'devices' }
  let(:factory)    { 'device' }

  context 'PUT /devices/:id/properties' do

    let(:resource)   { FactoryGirl.create :device, :with_no_physical, resource_owner_id: user.id }
    let(:status)     { Property.find resource.properties.first.id }
    let(:intensity)  { Property.find resource.properties.last.id }
    let(:properties) { [ { uri: a_uri(status), value: 'updated' }, { uri: a_uri(intensity), value: '20' } ] }
    let(:params)     { { pending: true, properties: properties } }
    let(:update)     { page.driver.put uri, params.to_json }

    let(:uri) { "/devices/#{resource.id}/properties" }

    it_behaves_like 'an updatable resource'
    it_behaves_like 'a not owned resource', 'page.driver.put(uri)'
    it_behaves_like 'a not found resource', 'page.driver.put(uri)'
    it_behaves_like 'a filterable resource', 'page.driver.put(uri)'
    it_behaves_like 'a registered event', 'page.driver.put(uri, params.to_json)'

    it 'creates an history resource' do
      expect { update }.to change { History.count }.by(1)
    end

    it 'creates an history resource' do
      expect { update }.to change { resource.reload.pending }.from(false).to(true)
    end

    it 'updates #updated_at' do
      old = Time.now - 60
      resource.update_attributes(updated_at: old)
      expect { update }.to change { resource.reload.updated_at.to_i }
    end

    context 'with a not existing property' do

      let(:another) { FactoryGirl.create :property }
      let(:params)  { { properties: [ { uri: a_uri(another), value: 'not-valid' } ] } }

      it 'raises a not found property' do
        page.driver.put(uri, params.to_json)
        has_not_found_resource uri: params[:properties].map {|p| p[:uri]}
      end

      it 'does not create an history resource' do
        expect { update }.to_not change { History.count }.by(1)
      end
    end

    context 'with no physical connection' do

      before { update }

      it 'returns status code OK' do
        page.status_code.should == 200
      end
    end

    context 'with physical connection' do

      let(:resource) { FactoryGirl.create :device, resource_owner_id: user.id }

      before { update }

      it 'returns status code Accepted' do
        page.status_code.should == 202
      end
    end

    describe 'when the request comes from the physical device' do

      let(:product)     { FactoryGirl.create :product }
      let(:article)     { product.articles.first }
      let(:article_uri) { a_uri(article) }

      before { resource.update_attributes( { physical: { uri: a_uri(article) } }) }

      describe 'with valid signature' do

        let(:signature) { Signature.sign(params, product.secret) }

        before { page.driver.header 'X-Physical-Signature', signature }
        before { page.driver.put "#{uri}?source=physical", params.to_json }

        it 'gets a 200 response' do
          page.status_code.should == 200
        end
      end

      describe 'with an invalid signature' do

        let(:signature) { Signature.sign(params, 'not-valid-secret') }

        before { page.driver.header 'X-Physical-Signature', signature }
        before { page.driver.put "#{uri}?source=physical", params.to_json }

        it 'gets a 401 response' do
          page.status_code.should == 401
        end
      end

      describe 'whit no signature' do

        before { page.driver.put "#{uri}?source=physical", params.to_json }

        it 'gets a 401 response' do
          page.status_code.should == 401
        end
      end

      describe 'with X-Request-Source header set with physical' do

        let(:signature) { Signature.sign(params, product.secret) }

        before { page.driver.header 'X-Physical-Signature', signature }
        before { page.driver.header 'X-Request-Source', 'physical' }
        before { page.driver.put uri, params.to_json }

        it 'gets a 200 response' do
          page.status_code.should == 200
        end
      end
    end
  end
end
