# Type JSON stubbing
stub_request(:get, Settings.type.uri).to_return(body: Settings.type_json)

# Function JSON stubbing
stub_request(:get, Settings.functions.set_intensity.uri).to_return(body: Settings.function_json)

# Unite Node POST JSON stubbing
stub_request(:post, Settings.unite_node.uri).
  with(:body => /.*/).
  with(:query => {id: Settings.unite_node.physical_id}).
  to_return(body: Settings.unite_node_json)
