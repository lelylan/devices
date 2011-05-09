def new_device_properties
  HashWithIndifferentAccess.new(JSON.parse(Settings.unite_node_json))[:properties]
end
