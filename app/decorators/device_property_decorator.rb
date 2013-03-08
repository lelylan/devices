class DevicePropertyDecorator < ApplicationDecorator
  decorates :DeviceProperty

  def uri
    "#{h.request.protocol}#{types_host}/properties/#{source.property_id}"
  end
end
