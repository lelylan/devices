shared_examples_for 'a sourceable resource' do

  describe '#source' do

    describe 'when the request comes from lelylan' do

      before { page.driver.put uri, params.to_json }
      before { resource.reload }

      describe 'when the user#email is defined' do

        before { user.update_attributes(full_name: nil, username: nil) }
        before { page.driver.put uri, params.to_json }
        before { resource.reload }

        it 'gets the full name user as #source' do
          json = JSON.parse(page.source)
          json = Hashie::Mash.new json
          json.source.should == 'alice@example.com'
        end
      end

      describe 'when the user#username is defined' do

        before { user.update_attributes(full_name: nil) }
        before { page.driver.put uri, params.to_json }
        before { resource.reload }

        it 'gets the full name user as #source' do
          json = JSON.parse(page.source)
          json = Hashie::Mash.new json
          json.source.should == 'alice'
        end
      end

      describe 'when the user#full_name is defined' do

        before { page.driver.put uri, params.to_json }
        before { resource.reload }

        it 'gets the user full name as source' do
          json = JSON.parse(page.source)
          json = Hashie::Mash.new json
          json.source.should == 'Alice Wonderland'
        end
      end
    end


    describe 'when the request comes from the physical device' do

      before { page.driver.header 'Authorization', nil }
      before { page.driver.header 'X-Physical-Secret', resource.secret }
      before { page.driver.put uri, params.to_json }

      it 'gets a physical source' do
        json = JSON.parse(page.source)
        json = Hashie::Mash.new json
        json.source.should == 'physical'
      end
    end
  end
end
