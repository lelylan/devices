class DeviceDecorator < ApplicationDecorator
  decorates :Device

  def uri
    h.url_for controller: 'devices', action: 'show', id: model.id, only_path: false
    # , host: (params[:host] || request.host_with_port)
  end
end
