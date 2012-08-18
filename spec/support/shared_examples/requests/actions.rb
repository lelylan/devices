shared_examples_for 'a listable resource' do

  let!(:not_owned) { FactoryGirl.create factory }

  it 'shows all owned resources' do
    page.driver.get uri
    page.status_code.should == 200
    contains_owned_resource resource
    does_not_contain_resource not_owned
  end
end

shared_examples_for 'a showable resource' do

  it 'view the owned resource' do
    page.driver.get uri
    page.status_code.should == 200
    has_resource resource
  end
end

shared_examples_for 'a creatable resource' do

  let(:klass)    { controller.classify.constantize }

  it 'creates the resource' do
    page.driver.post uri, params.to_json
    resource = klass.last
    page.status_code.should == 201
    has_resource resource
  end

  it 'stores the resource' do
    expect { page.driver.post(uri, params.to_json) }.to change { klass.count }.by(1)
  end
end

shared_examples_for 'an updatable resource' do

  it 'updates the resource' do
    page.driver.put uri, params.to_json
    resource.reload
    page.status_code.should == 200
    page.should have_content 'updated'
    has_resource resource
  end
end


shared_examples_for 'a deletable resource' do

  let(:klass)    { controller.classify.constantize }

  it 'deletes the resource' do
    expect { page.driver.delete(uri) }.to change{ klass.count }.by(-1)
    page.status_code.should == 200
    has_resource resource
  end
end
