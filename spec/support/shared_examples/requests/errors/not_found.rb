shared_examples_for 'a not found resource' do |action|

  context 'with not existing resource' do

    scenario 'get a not found notification' do
      resource.delete
      eval action
      has_valid_json
      has_not_found_resource uri: uri
    end
  end
end
