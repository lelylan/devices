class DeviceDecorator < ApplicationDecorator
  decorates :Device

  def uri
    base_uri('devices')
  end
end
