# Helpers method
def authenticated(path)
  protocol = "https://"
  path = path.gsub(protocol, '')
  path = "#{Lelylan::Type.username}:#{Lelylan::Type.password}@#{path}"
  path = "#{protocol}#{path}"
  return path
end

# Type JSON stubbing
stub_request(:get, authenticated(Settings.type.uri)).to_return(body: Settings.type_json)
stub_request(:get, authenticated(Settings.type_range.uri)).to_return(body: Settings.type_range_json)

# Function JSON stubbing
stub_request(:get, authenticated(Settings.functions.set_intensity.uri)).to_return(body: Settings.function_json)

# Unite Node PUT JSON stubbing
stub_request(:put, Settings.unite_node.uri).
  with(:body => /.*/).
  with(:query => {id: Settings.unite_node.physical_id}).
  to_return(body: Settings.unite_node_json)

