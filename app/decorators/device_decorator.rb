class DeviceDecorator < ApplicationDecorator
  decorates :Device

  def uri
    host = h.params[:host] || h.request.host_with_port
    h.url_for controller: 'devices', action: 'show', id: model.id, only_path: false, host: host
  end
end
