class User
  include Mongoid::Document
  store_in session: 'people'
end
