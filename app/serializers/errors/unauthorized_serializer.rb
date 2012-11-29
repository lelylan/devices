class UnauthorizedSerializer < ActiveModel::Serializer
  attributes :status, :method, :request, :error

  def status
    401
  end

  def method
    scope.method
  end

  def request
    scope.url
  end

  def error
    { code: 'notifications.access.not_authorized',
      description: I18n.t('notifications.access.not_authorized') }
  end
end
