class HistoryDecorator < ApplicationDecorator
  decorates :History

  def uri
    h.history_path(model, default_options)
  end

  def device_uri
    h.device_path(device_id, default_options)
  end
end
