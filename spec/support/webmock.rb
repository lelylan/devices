# Type JSON stubbing
stub_request(:get, Settings.type.uri).to_return(body: Settings.type_json)

# Function JSON stubbing
stub_request(:get, Settings.functions.intensity.uri).to_return(body: Settings.function_json)
