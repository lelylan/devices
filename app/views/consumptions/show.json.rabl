object ConsumptionDecorator.decorate(@consumption)

node(:uri)      { |c| c.uri }
node(:id)       { |c| c.id }
node(:device)   { |c| { uri: c.device_uri } }
node(:type)     { |c| c.type }
node(:value)    { |c| c.value }
node(:unit)     { |c| c.unit }
node(:occur_at) { |c| c.occur_at }

node(:end_at, :if => lambda { |c| c.durational? }) do |c|
  c.end_at
end

node(:duration, :if => lambda { |c| c.durational? }) do |c|
  c.duration
end
