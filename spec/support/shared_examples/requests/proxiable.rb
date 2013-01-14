shared_examples_for 'a proxiable resource' do

  let(:decorator)  { "#{controller.classify}Decorator".constantize }
  let(:changeable) { decorator.decorate(resource) }

  it 'exposes the resource URI' do
    page.driver.get uri
    uri = "http://www.example.com/#{controller}/#{changeable.id}"
    changeable.uri.should == uri
  end

  context 'with x-host header' do

    before { page.driver.header 'x-host', 'api.lelylan.com' }

    it 'changes the URI' do
      page.driver.get uri
      changeable.uri.should match('http://api.lelylan.com')
    end
  end
end
