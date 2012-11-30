module Viewable
  extend ActiveSupport::Concern

  def render_401
    self.class.serialization_scope :request
    render json: {}, status: 401, serializer: ::UnauthorizedSerializer and return
  end

  def render_404(code = 'notifications.resource.not_found', uri = nil)
    self.class.serialization_scope :request
    resource = { code: code, description: I18n.t(code), uri: (uri || request.url) }
    render json: resource, status: 404, serializer: ::NotFoundSerializer and return
  end

  def render_422(code, description)
    self.class.serialization_scope :request
    resource = { code: code, description: description, body: json_body }
    render json: resource, status: 422, serializer: ::NotValidSerializer and return
  end

  private

  def json_body
    key  = request.path_parameters[:controller].singularize
    json = request.request_parameters
    json[key]
  end
end
