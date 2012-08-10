object HistoryDecorator.decorate(@history)

node(:uri)    { |history| history.uri }
node(:id)     { |history| history.id }
node(:device) { |history| { uri: history.device_uri } }

node(:properties) do |history|
  history.properties.map do |property|
    property = HistoryPropertyDecorator.decorate(property)
    { uri: property.uri, value: property.value, physical: property.physical }
  end
end

node(:created_at) { |history| history.created_at }
