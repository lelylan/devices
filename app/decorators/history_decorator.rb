class HistoryDecorator < ApplicationDecorator
  decorates :History

  def uri
    base_uri('histories')
  end
end
