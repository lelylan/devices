class User
  include Mongoid::Document
  store_in session: 'people'

  field :email
  field :rate_limit
  field :encrypted_password
end
