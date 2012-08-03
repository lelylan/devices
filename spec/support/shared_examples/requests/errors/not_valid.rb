shared_examples_for 'a validated resource' do |action, options|

  it 'does not create a resource' do
    eval(action)
    page.status_code.should == 422
    has_a_not_valid_resource options
  end
end

shared_examples_for 'a parsable json input' do |action, options|

  it 'shows a not valid response' do
    params = 'not-valid'
    eval(action)
    page.status_code.should == 422
    has_a_not_valid_resource code: 'notifications.json.not_valid', error: 'Not valid', method: options[:method]
    page.should have_content params
  end
end
