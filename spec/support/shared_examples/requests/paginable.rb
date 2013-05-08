shared_examples_for 'a paginable resource' do

  before { Settings.pagination.per = 1 }
  before { Settings.pagination.max_per = 2 }

  let(:decorator)  { "#{controller.classify}Decorator".constantize }

  let!(:resource)  { decorator.decorate(FactoryGirl.create(factory, resource_owner_id: user.id)) }
  let!(:resources) { FactoryGirl.create_list(factory, Settings.pagination.per + 1, resource_owner_id: user.id) }

  describe '?start=:uri' do

    it 'shows the next page' do
      page.driver.get uri, start: resource.uri
      page.status_code.should == 200
      contains_resource resources.last
      page.should_not have_content resource.id.to_s
    end
  end

  describe '?per=:nil' do

    it 'shows the default number of resources' do
      page.driver.get uri
      JSON.parse(page.source).should have(Settings.pagination.per).items
    end
  end

  describe '?per=1' do

    it 'shows 1 resource' do
      page.driver.get uri, per: 1
      JSON.parse(page.source).should have(1).items
    end
  end

  context '?per=100000' do

    it 'shows the max number of allowed resources' do
      page.driver.get uri, per: 100000
      JSON.parse(page.source).should have(Settings.pagination.max_per).items
    end
  end

  context '?per=not-valid' do

    it 'shows the default number of resources' do
      page.driver.get uri, per: 'not-valid'
      JSON.parse(page.source).should have(Settings.pagination.per).items
    end
  end
end
