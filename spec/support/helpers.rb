def mock_headers 
  {'Accept'=>'application/json', 'Content-Type' => 'application/json'}
end

# Expectations
def a_get(path)
  a_request(:get, authenticated(path))
end

def a_public_get(path)
  a_request(:get, path)
end

def a_post(path)
  a_request(:post, authenticated(path))
end

def a_put(path, auth=true)
  path = authenticated(path) if auth
  a_request(:put, path)
end

def a_delete(path)
  a_request(:delete, authenticated(path))
end


# Stubs
def stub_get(path, auth=true)
  path = authenticated(path) if auth
  stub_request(:get, path).with(headers: mock_headers)
end

def stub_post(path, auth=true)
  path = authenticated(path) if auth
  stub_request(:post, path).with(headers: mock_headers)
end

def stub_put(path, auth=true)
  path = authenticated(path) if auth
  stub_request(:put, path).with(headers: mock_headers)
end

def stub_delete(path, auth=true)
  path = authenticated(path) if auth
  stub_request(:delete, path).with(headers: mock_headers)
end


# Fixtures
def fixture_path
  File.expand_path("../../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def json_fixture(file)
  HashWithIndifferentAccess.new JSON.parse fixture(file).read
end


# URI generators
def a_uri(resource, id = :id)
  "http://www.example.com/#{resource.class.to_s.pluralize.downcase}/#{resource[id]}"
end
