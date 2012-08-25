# Let access the filtered devices defined in the access token.

module Filterable
  extend ActiveSupport::Concern

  included do
    field :device_ids, type: Array, default: []
  end
end
