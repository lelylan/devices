<<<<<<< HEAD
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

# Basic Authenticatin definition
def authenticated(path)
  protocol = "https://"
  path = path.gsub(protocol, '')
  path = "#{Lelylan::Type.username}:#{Lelylan::Type.password}@#{path}"
  path = "#{protocol}#{path}"
  return path
end

=======
def new_device_properties
  HashWithIndifferentAccess.new(JSON.parse(Settings.unite_node_json))[:properties]
end
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
