class ConsumptionDecorator < ApplicationDecorator
  decorates :Consumption

  def uri
    h.consumption_path(model, default_options)
  end

  def device_uri
    h.device_path(device_id, default_options)
  end
end
