shared_examples_for 'a sourceable resource' do

  describe '#updated_from' do

    describe 'when the request comes from lelylan' do

      before { page.driver.put uri, params.to_json }
      before { resource.reload }

      describe 'when user#email is defined' do

        before { user.update_attributes(full_name: nil, username: nil) }
        before { page.driver.put uri, params.to_json }
        before { resource.reload }

        it 'gets #email' do
          json = JSON.parse(page.source)
          json = Hashie::Mash.new json
          json.updated_from.should == 'alice@example.com'
        end
      end

      describe 'when user#username is defined' do

        before { user.update_attributes(full_name: nil) }
        before { page.driver.put uri, params.to_json }
        before { resource.reload }

        it 'gets #nameuser' do
          json = JSON.parse(page.source)
          json = Hashie::Mash.new json
          json.updated_from.should == 'alice'
        end
      end

      describe 'when user#full_name is defined' do

        before { page.driver.put uri, params.to_json }
        before { resource.reload }

        it 'gets #full_name' do
          json = JSON.parse(page.source)
          json = Hashie::Mash.new json
          json.updated_from.should == 'Alice Wonderland'
        end
      end
    end


    describe 'when the request comes from the physical device' do

      before { page.driver.header 'Authorization', nil }
      before { page.driver.header 'X-Physical-Secret', resource.secret }
      before { page.driver.put uri, params.to_json }

      it 'gets #physical' do
        json = JSON.parse(page.source)
        json = Hashie::Mash.new json
        json.updated_from.should == 'physical'
      end
    end
  end
end
