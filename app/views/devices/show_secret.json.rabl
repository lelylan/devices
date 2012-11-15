object DeviceDecorator.decorate(@device)

node(:uri)    { |d| d.uri }
node(:id)     { |d| d.id }
node(:name)   { |d| d.name }
node(:secret) { |d| d.secret }
