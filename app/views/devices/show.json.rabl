object DeviceDecorator.decorate(@device)

node(:uri)  { |d| d.uri }
node(:id)   { |d| d.id }
node(:name) { |d| d.name }
node(:type) { |d| { uri: d.type_uri } }

node(:properties) do |d|
  d.properties.map do |p|
    p = DevicePropertyDecorator.decorate p
    { uri: p.uri, id: p.id, value: p.value, physical: p.physical }
  end
end

node(:physical) do |d|
  d.physical ? { uri: d.physical.uri } : { }
end

node(:activated)  { |d| d.activated_at ? true : false }
node(:pending)    { |d| d.pending }
node(:created_at) { |d| d.created_at }
node(:updated_at) { |d| d.updated_at }
