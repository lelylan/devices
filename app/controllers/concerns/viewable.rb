module Viewable
  extend ActiveSupport::Concern

  def doorkeeper_unauthorized_render_options
    { template: 'shared/401', status: 401 }
  end

  def render_401
    render 'shared/404', status: 401 and return
  end

  def render_404(code = 'notifications.resource.not_found', uri = nil)
    self.class.serialization_scope :request
    resource = { code: code, description: I18n.t(code), uri: (uri || request.url) }
    render 'show', status: 404, json: resource, serializer: ::NotFoundSerializer and return
  end

  def render_422(code, error)
    @body  = json_body
    @code  = code
    @error = error
    render 'shared/422', status: 422 and return
  end

  private

  def json_body
    key  = request.path_parameters[:controller].singularize
    json = request.request_parameters
    json[key]
  end
end
