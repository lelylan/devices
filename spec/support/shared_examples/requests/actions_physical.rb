shared_examples_for 'an updatable resource from physical' do

  describe 'when the request comes from the physical device' do

    before { page.driver.header 'Authorization', nil }

    describe 'with valid signature' do

      let(:signature) { Signature.sign(params, resource.secret) }

      before { page.driver.header 'X-Physical-Signature', signature }
      before { page.driver.put uri, params.to_json }

      it 'gets a 200 response' do
        page.status_code.should == 200
      end
    end

    describe 'with an invalid signature' do

      let(:signature) { Signature.sign(params, 'not-valid-secret') }

      before { page.driver.header 'X-Physical-Signature', signature }
      before { page.driver.put uri, params.to_json }

      it 'gets a 401 response' do
        page.status_code.should == 401
      end
    end

    describe 'with no signature' do

      before { page.driver.put uri, params.to_json }

      it 'gets a 401 response' do
        page.status_code.should == 401
      end
    end
  end
end

shared_examples_for 'a creatable resource from physical' do |action|

  describe 'when the request comes from the physical device' do

    before { page.driver.header 'Authorization', nil }

    describe 'with valid signature' do

      let(:signature) { Signature.sign(params, device.secret) }

      before { page.driver.header 'X-Physical-Signature', signature }
      before { page.driver.post uri, params.to_json }

      it 'gets a 201 response' do
        page.status_code.should == 201
      end
    end

    describe 'with an invalid signature' do

      let(:signature) { Signature.sign(params, 'not-valid-secret') }

      before { page.driver.header 'X-Physical-Signature', signature }
      before { page.driver.post uri, params.to_json }

      it 'gets a 401 response' do
        page.status_code.should == 401
      end
    end

    describe 'with no signature' do

      before { page.driver.post uri, params.to_json }

      it 'gets a 401 response' do
        page.status_code.should == 401
      end
    end
  end
end

