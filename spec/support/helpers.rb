def new_device_properties
  res = HashWithIndifferentAccess.new(JSON.parse(Settings.unite_node_json))[:properties]
  return res
end
