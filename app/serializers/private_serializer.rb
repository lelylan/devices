class PrivateSerializer < ApplicationSerializer
  cached true

  attributes :uri, :id, :name, :secret, :activation_code

  def uri
    object[:uri]
  end

  def id
    object[:id]
  end

  def name
    object[:name]
  end

  def secret
    object[:secret]
  end

  def activation_code
    object[:activation_code]
  end
end
