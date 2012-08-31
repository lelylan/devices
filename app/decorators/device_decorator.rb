class DeviceDecorator < ApplicationDecorator
  decorates :Device

  def uri
    h.device_path(model, default_options)
  end

  def type_uri
    "#{h.request.protocol}#{type_host}/types/#{model.type_id}"
  end
end
