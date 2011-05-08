def changed_properties_from_json
  HashWithIndifferentAccess.new(JSON.parse(Settings.unite_node_json))[:properties]
end
