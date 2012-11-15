class Product
  include Mongoid::Document
  store_in session: 'products'

  field :secret
  embeds_many :articles
end
