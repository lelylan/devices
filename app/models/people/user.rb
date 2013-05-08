class User
  include Mongoid::Document
  store_in session: 'people'

  field :email
  field :full_name
  field :username
  field :encrypted_password
  field :rate_limit
end
