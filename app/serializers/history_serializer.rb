class HistorySerializer < ApplicationSerializer
  cached true

  attributes :uri, :id, :device, :source, :properties, :created_at, :updated_at

  def uri
    HistoryDecorator.decorate(object).uri
  end

  def device
    { uri: HistoryDecorator.decorate(object).device_uri }
  end

  def properties
    object.properties.map do |property|
      property = HistoryPropertyDecorator.decorate property
      { uri: property.uri, id: property.id, value: property.value,
        expected: property.expected, pending: property.pending }
    end
  end
end
