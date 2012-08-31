class ApplicationDecorator < Draper::Base
  def default_options
    {only_path: false, host: h.request.host}
  end

  def type_host
    host = h.request.env['HTTP_X_HOST'] || ENV['LELYLAN_TYPES_URL'] || h.request.host
  end
end
