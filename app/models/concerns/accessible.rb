# Limits the accessible resources for a specific token.

module Accessible
  extend ActiveSupport::Concern

  included do
    field :device_ids,   type: Array,   default: []

    attr_accessible :device_ids, :resources

    index({ device_ids: 1 })
  end
end
