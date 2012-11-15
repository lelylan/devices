class Article
  include Mongoid::Document
  store_in session: 'products'

  embedded_in :product
end
