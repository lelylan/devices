class Location
  include Mongoid::Document

  store_in session: 'locations'

  field :resource_owner_id
  field :name
  field :device_ids, type: Array, default: []
end
