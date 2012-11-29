module Viewable
  extend ActiveSupport::Concern

  def doorkeeper_unauthorized_render_options
    { template: 'shared/401', status: 401 }
  end

  def render_401
    self.class.serialization_scope :request
    render 'show', status: 401, json: {}, serializer: ::UnauthorizedSerializer and return
    render 'shared/401', status: 401 and return
  end

  def render_404(code = 'notifications.resource.not_found', uri = nil)
    self.class.serialization_scope :request
    resource = { code: code, description: I18n.t(code), uri: (uri || request.url) }
    render 'show', status: 404, json: resource, serializer: ::NotFoundSerializer and return
  end

  def render_422(code, description)
    self.class.serialization_scope :request
    resource = { code: code, description: description, body: json_body }
    render 'show', status: 422, json: resource, serializer: ::NotValidSerializer and return
  end

  private

  def json_body
    key  = request.path_parameters[:controller].singularize
    json = request.request_parameters
    json[key]
  end
end
