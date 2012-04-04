class ApplicationDecorator < Draper::Base
  def default_options
    host = h.params[:host] || h.request.host_with_port
    {only_path: false, host: host}
  end
end
