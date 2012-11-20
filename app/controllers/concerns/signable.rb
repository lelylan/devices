# This module is used to check the signature of a request coming
# form the physical device in a not secure channel (HTTP)

module Signable
  extend ActiveSupport::Concern

  def verify_signature
    # I check only if the token is created from the lelylan physical client
    if doorkeeper_token.application_id == Defaults.phisical_application_id
      # get the signature
      signature  = request.headers['X-Physical-Signature']
      # remove a key that is automatically added by rails
      # do not remove function as it is a mandatory param (coincidentaly the one would be automatically added)
      payload = request.request_parameters.delete_if {|k, v| k == 'property' or k == 'device' }
      # unauthorize if the signature is not valid
      render_401 if @device and !Signature.valid?(signature, payload, @device.secret)
    end
  end
end
