shared_examples_for 'an updatable resource from physical' do

  describe 'when the request comes from the physical device' do

    before { page.driver.header 'Authorization', nil }

    describe 'with valid secret' do

      before { page.driver.header 'X-Physical-Secret', resource.secret }
      before { page.driver.put uri, params.to_json }

      it 'gets a 200 response' do
        page.status_code.should == 200
      end
    end

    describe 'with an invalid secret' do

      before { page.driver.header 'X-Physical-Secret', 'not-valid-secret' }
      before { page.driver.put uri, params.to_json }

      it 'gets a 401 response' do
        page.status_code.should == 401
      end
    end

    describe 'with no secret' do

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

    describe 'with valid secret' do

      before { page.driver.header 'X-Physical-Secret', device.secret }
      before { page.driver.post uri, params.to_json }

      it 'gets a 201 response' do
        page.status_code.should == 201
      end
    end

    describe 'with an invalid secret' do

      before { page.driver.header 'X-Physical-Secret', 'not-valid-secret' }
      before { page.driver.post uri, params.to_json }

      it 'gets a 401 response' do
        page.status_code.should == 401
      end
    end

    describe 'with no secret' do

      before { page.driver.post uri, params.to_json }

      it 'gets a 401 response' do
        page.status_code.should == 401
      end
    end
  end
end

