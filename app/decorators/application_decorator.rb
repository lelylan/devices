class ApplicationDecorator < Draper::Base
  def default_options
    {only_path: false, host: h.request.host}
  end
end
