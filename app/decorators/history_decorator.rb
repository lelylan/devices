class HistoryDecorator < ApplicationDecorator
  decorates :History

  def uri
    h.history_path(model, default_options)
  end
end
