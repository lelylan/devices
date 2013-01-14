shared_examples_for 'a crossable resource' do

  before  { page.driver.header 'Origin', 'http://test.com' }
  before  { page.driver.header 'Access-Control-Request-Method', 'POST' }

  before  { page.driver.get uri }

  it 'allows the request' do
    page.response_headers['Access-Control-Allow-Origin'].should   == 'http://test.com'
    page.response_headers['Access-Control-Allow-Methods'].should  == 'GET, POST, PUT, DELETE, OPTIONS'
    page.response_headers['Access-Control-Expose-Headers'].should == ''
  end
end
