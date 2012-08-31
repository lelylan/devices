class DevicePropertyDecorator < ApplicationDecorator
  decorates :DeviceProperty

  def uri
    "#{h.request.protocol}#{types_host}/properties/#{model.property_id}"
  end
end
