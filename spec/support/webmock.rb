# URI to stub
uri = Settings.type_stub.host + Settings.type_stub.path

## Stubbing
# Type request
stub_request(:get, uri).to_return(body: {name: "Dimmer"})

# Request
res = Net::HTTP.get( Settings.type_stub.host, Settings.type_stub.path)

# Result
puts ":::" + res.inspect
puts ":::" + res.class.inspect
