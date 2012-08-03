shared_examples_for 'a type connection' do

  let(:field) { "#{connection.singularize}_ids" }

  describe '#find_connection' do

    context 'when creates' do

      context 'with valid URIs' do

        let(:type) { FactoryGirl.create :type, :with_no_connections, connection => uris }

        it 'sets the connections' do
          type[field].should == ids
        end
      end

      context 'with empty connections' do

        let(:type) { FactoryGirl.create :type, connection => [] }

        it 'removes previous connections' do
          type[field].should have(0).items
        end
      end

      context 'with not valid connection uri' do

        let(:type) { FactoryGirl.create :type, connection => [ 'not-valid' ] }

        it 'raises an error' do
          expect { type }.to raise_error Mongoid::Errors::Validations
        end
      end

      context 'with not valid json' do

        let(:type) { FactoryGirl.create(:type, connection => 'not-valid') }

        it 'raises an error' do
          expect { type }.to raise_error
        end
      end
    end

    context 'when updates' do

      context 'with new connections' do

        let(:type)     { FactoryGirl.create :type }
        let!(:old_ids) { type[field] }

        before         { type.update_attributes connection => uris }
        let!(:new_ids) { type[field] }

        it 'sets the new connections' do
          new_ids.should_not == old_ids
        end
      end

      context 'with not valid uris' do

        let(:type)   { FactoryGirl.create :type }
        let(:update) { type.update_attributes! connection => 'not-valid' }

        it 'raises an error' do
          expect { update }.to raise_error Mongoid::Errors::Validations
        end
      end
    end
  end
end
