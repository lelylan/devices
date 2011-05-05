# URI to stub
uri = Settings.type_stub.host + Settings.type_stub.path

# Type Stubbing
stub_request(:get, uri).to_return(body: Settings.type_json)

# Request
res = Net::HTTP.get( Settings.type_stub.host, Settings.type_stub.path)

# Result
puts ":::" + JSON.parse(res).inspect
