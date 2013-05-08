class DeviceDecorator < ApplicationDecorator
  decorates :Device

  def uri
    h.device_path(model, default_options)
  end

  def type_uri
    "#{h.request.protocol}#{types_host}/types/#{model.type_id}"
  end

  def owner_uri
    "#{h.request.protocol}#{people_host}/people/#{model.resource_owner_id}"
  end

  def maker_uri
    "#{h.request.protocol}#{people_host}/people/#{model.maker_id}"
  end
end
