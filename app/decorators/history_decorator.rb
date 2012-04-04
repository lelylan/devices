class HistoryDecorator < ApplicationDecorator
  decorates :History

  def uri(device_id)
    h.device_history_path(model, device_id, default_options)
  end
end
