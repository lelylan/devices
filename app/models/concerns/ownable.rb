# Ownable
#
# Add the field resource_owner_id to show only the owned resources.
# Used to show owned applications in doorkeeper.

module Ownable
  extend ActiveSupport::Concern

  included do
    field          :resource_owner_id, type: Moped::BSON::ObjectId
    attr_protected :resource_owner_id
    validates      :resource_owner_id, presence: true

    index({ resource_owner_id: 1 })
  end
end
