class NotFoundSerializer < ActiveModel::Serializer
  attributes :status, :method, :request, :error

  def status
    404
  end

  def method
    scope.method
  end

  def request
    scope.url
  end

  def error
    { code: object[:code],
      description: object[:description],
      uri: object[:uri] }
  end
end
