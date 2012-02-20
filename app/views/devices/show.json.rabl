object @device

attributes :uri, :id, :name, :type_uri

child :device_properties do
  attributes :uri, :value
end

child :physical do
  attributes :uri
end

attributes :created_at, :updated_at
