require 'openssl'

class Signature

  def self.valid?(signature, payload, secret)
    signature == Signature.sign(payload, secret)
  end

  def self.sign(payload, secret)
    digest = OpenSSL::Digest::Digest.new('sha1')
    OpenSSL::HMAC.hexdigest(digest, secret, payload.to_json.to_s)
  end
end
