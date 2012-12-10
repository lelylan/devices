class User
  include Mongoid::Document
  store_in session: 'people'

  field :email
  field :encrypted_password
  field :rate_limit
end
