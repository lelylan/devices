class ConsumptionSerializer < ApplicationSerializer
  cached true

  attributes :uri, :id, :device, :type, :value, :unit, :occur_at, :end_at, :duration

  def uri
    ConsumptionDecorator.decorate(object).uri
  end

  def device
    { uri: ConsumptionDecorator.decorate(object).device_uri }
  end

  def include_end_at?
    object.duration?
  end

  def include_duration?
    object.durational?
  end
end
