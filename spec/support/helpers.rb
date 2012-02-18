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

def a_put(path, type='basic')
  path = authenticated(path) if type=='basic'
  a_request(:put, path)
end

def a_delete(path)
  a_request(:delete, authenticated(path))
end


# Stubs
def stub_get(path)
  stub_request(:get, authenticated(path)).
    with(headers: {'Accept'=>'application/json', 'Content-Type' => 'application/json'})
end

def stub_public_get(path)
  stub_request(:get, path).
    with(headers: {'Accept'=>'application/json', 'Content-Type' => 'application/json'})
end

def stub_post(path)
  stub_request(:post, authenticated(path)).
    with(headers: {'Accept'=>'application/json', 'Content-Type' => 'application/json'})
end

def stub_put(path)
  stub_request(:put, authenticated(path)).
    with(headers: {'Accept'=>'application/json', 'Content-Type' => 'application/json'})
end

def stub_delete(path)
  stub_request(:delete, authenticated(path)).
    with(headers: {'Accept'=>'application/json', 'Content-Type' => 'application/json'})
end


# Fixtures
def fixture_path
  File.expand_path("../../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end


# Basic Authenticatin definition
def authenticated(path)
  protocol = "https://"
  path = path.gsub(protocol, '')
  path = "#{Lelylan::Type.username}:#{Lelylan::Type.password}@#{path}"
  path = "#{protocol}#{path}"
  return path
end

# Device properties
# TODO: remove and find a much better way to do this
def new_device_properties
  HashWithIndifferentAccess.new(JSON.parse(Settings.unite_node_json))[:properties]
end
