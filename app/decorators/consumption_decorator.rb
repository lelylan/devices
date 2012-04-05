class ConsumptionDecorator < ApplicationDecorator
  decorates :Consumption

  def uri
    h.consumption_path(model, default_options)
  end
end
