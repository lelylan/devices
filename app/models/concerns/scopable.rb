# Let access the scoped devices on the access token. 
# Devices are used to limit the accessible resources per token.
module Scopable
  extend ActiveSupport::Concern

  included do
    field :devices, type: Array, default: []
  end
end
