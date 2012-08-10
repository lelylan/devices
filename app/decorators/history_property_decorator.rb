class HistoryPropertyDecorator < ApplicationDecorator
  decorates :HistoryProperty

  def property_host
    host = h.params[:host] || 'http://types.lelylan.com'
  end

  def uri
    "#{property_host}/properties/#{model.property_id}"
  end
end
