class DeviceDecorator < ApplicationDecorator
  decorates :Device

  def uri
    h.device_path(model, default_options)
  end

  def type_host
    host = h.params[:host] || 'http://types.lelylan.com'
  end

  def type_uri
    "#{type_host}/types/#{model.type_id}"
  end
end
