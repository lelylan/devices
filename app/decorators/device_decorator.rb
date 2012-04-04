class DeviceDecorator < ApplicationDecorator
  decorates :Device

  def uri
    h.device_path(model, default_options)
  end
end
