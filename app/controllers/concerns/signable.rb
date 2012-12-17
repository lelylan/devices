# Check the signature of a coming request from the physical device.
#
# This is used to avoid the usage of an Access Token
# * unsecure channels
# * extra step to ask the access token (must be invisible)

module Signable
  extend ActiveSupport::Concern

  def verify_signature
    if request.headers['X-Physical-Signature']
      signature = request.headers['X-Physical-Signature']
      payload   = request.request_parameters
      render_401 if @device and !Signature.valid?(signature, payload, @device.secret)
    end
  end
end
