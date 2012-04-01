class ApplicationDecorator < Draper::Base
  def base_uri(controller)
    host = h.params[:host] || h.request.host_with_port
    h.url_for controller: controller, action: 'show', id: model.id, only_path: false, host: host 
  end
end
