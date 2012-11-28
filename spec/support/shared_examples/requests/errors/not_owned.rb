shared_examples_for 'a not owned resource' do |action|

  context 'with resource not owned' do

    let!(:not_owned) { FactoryGirl.create factory }
    let!(:uri)       { "/#{controller}/#{not_owned.id}" }

    scenario 'get a not found notification' do
      eval action
      save_and_open_page
      has_valid_json
      has_not_found_resource uri: uri
    end
  end
end
