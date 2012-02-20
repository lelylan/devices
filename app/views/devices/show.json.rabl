object @device => false

attributes :uri, :id, :name
attributes :created_at, :updated_at

node :type do |device|
  { :uri => device.type_uri }
end

child :device_properties do
  attribute :uri
end

child :device_properties do
  attribute :uri
end

