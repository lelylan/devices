shared_examples_for 'a paginable resource' do

  let(:decorator)  { "#{controller.classify}Decorator".constantize }

  let!(:resource)  { decorator.decorate(FactoryGirl.create(factory, resource_owner_id: user.id)) }
  let!(:resources) { FactoryGirl.create_list(factory, Settings.pagination.per + 5, resource_owner_id: user.id) }

  describe '?start=:uri' do

    it 'shows the next page' do
      page.driver.get uri, start: resource.uri
      page.status_code.should == 200
      contains_resource resources.first
      page.should_not have_content resource.id.to_s
    end
  end

  describe '?per=:nil' do

    it 'shows the default number of resources' do
      page.driver.get uri
      JSON.parse(page.source).should have(Settings.pagination.per).items
    end
  end

  describe '?per=5' do

    it 'shows 5 resources' do
      page.driver.get uri, per: 5
      JSON.parse(page.source).should have(5).items
    end
  end

  context '?per=100000' do

    before { Settings.pagination.max_per = 30 }

    it 'shows the max number of allowed resources' do
      page.driver.get uri, per: 100000
      JSON.parse(page.source).should have(30).items
    end
  end

  context '?per=not-valid' do

    it 'shows the default number of resources' do
      page.driver.get uri, per: 'not-valid'
      JSON.parse(page.source).should have(Settings.pagination.per).items
    end
  end
end
