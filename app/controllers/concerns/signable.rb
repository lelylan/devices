# Check the signature of a coming request from the physical device.
#
# This is used to avoid the usage of an Access Token
# * unsecure channels
# * extra step to ask the access token (must be invisible)

module Signable
  extend ActiveSupport::Concern

  def verify_secret
    if request.headers['X-Physical-Secret']
      secret = request.headers['X-Physical-Secret']
      render_401 if @device and @device.secret != secret
    end
  end
end
