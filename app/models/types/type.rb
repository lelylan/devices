class Type
  include Mongoid::Document
  store_in session: 'types'

  field :resource_owner_id, type: Moped::BSON::ObjectId
  field :name
  field :category, type: Array, default: []
  field :property_ids, type: Array, default: []
end
