shared_examples_for 'a public listable resource' do

  let!(:not_owned) { FactoryGirl.create factory }

  it 'shows all resources (owned and not owned)' do
    page.driver.get uri
    page.status_code.should == 200
    JSON.parse(page.source).should have(2).items
  end
end

shared_examples_for 'a public resource' do |action|

  let!(:not_owned) { FactoryGirl.create factory }
  let(:uri)        { "/#{controller}/#{not_owned.id}" }

  it 'does not create a resource' do
    eval action
    page.status_code.should == 200
  end
end
