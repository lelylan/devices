stub_request(:get, Settings.stub.type_uri)
res = Net::HTTP.get(Settings.type_host.gsub("http://", ""), "/types/dimmer")
puts "::::" + res.inspect
