object DeviceDecorator.decorate(@device)

node(:uri)    { |d| d.uri }
node(:id)     { |d| d.id }
node(:name)   { |d| d.name }

node(:secret)          { |d| d.secret }
node(:activation_code) { |d| Signature.sign(d.id, d.secret) }
