class NotValidSerializer < ActiveModel::Serializer
  attributes :status, :method, :request, :error

  def status
    422
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
      body: object[:body] }
  end
end
