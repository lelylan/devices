class Function
  include Mongoid::Document
  store_in session: 'types'

  field :resource_owner_id
  field :name

  attr_accessible :name, :properties

  embeds_many :properties, class_name: 'FunctionProperty', cascade_callbacks: true
end
