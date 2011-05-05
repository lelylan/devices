# URI to stub
# Type JSON stubbing
# TODO: the returned value must come from VCR
stub_request(:get, Settings.type.uri).to_return(body: Settings.type_json)
