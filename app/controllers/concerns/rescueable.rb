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
end
