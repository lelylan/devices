module Rescueable
  extend ActiveSupport::Concern

  included do
    rescue_from Mongoid::Errors::DocumentNotFound, with: :document_not_found
    rescue_from Mongoid::Errors::Validations,      with: :document_not_valid
    rescue_from MultiJson::DecodeError,            with: :json_error
  end


  def document_not_found
    render_404 'notifications.resource.not_found'
  end

  def document_not_valid(e)
    render_422 'notifications.resource.not_valid', e.message
  end

  def json_error(e)
    code = 'notifications.json.not_valid'
    render_422 code, I18n.t(code)
  end


  def render_401
    self.class.serialization_scope :request
    render json: {}, status: 401, serializer: ::NotAuthorizedSerializer and return
  end

  def render_404(code = 'notifications.resource.not_found', uri = nil)
    self.class.serialization_scope :request
    resource = { code: code, description: I18n.t(code), uri: (uri || request.url) }
    render json: resource, status: 404, serializer: ::NotFoundSerializer and return
  end

  def render_422(code, description)
    self.class.serialization_scope :request
    resource = { code: code, description: description, body: request.request_parameters }
    render json: resource, status: 422, serializer: ::NotValidSerializer and return
  end
end
