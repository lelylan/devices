object HistoryDecorator.decorate(@history)

node(:uri)    { |history| history.uri }
node(:id)     { |history| history.id }
node(:device) { |history| { uri: history.device_uri } }

node(:properties) do |history|
  history.history_properties.map do |property|
    { uri: property.uri, value: property.value }
  end
end

node(:created_at) { |history| history.created_at }
node(:updated_at) { |history| history.updated_at }
