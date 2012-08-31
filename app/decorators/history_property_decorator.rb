class HistoryPropertyDecorator < ApplicationDecorator
  decorates :HistoryProperty

  def uri
    "#{h.request.protocol}#{type_host}/properties/#{model.property_id}"
  end
end
