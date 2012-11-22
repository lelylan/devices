class User
  include Mongoid::Document
  store_in session: 'people'

  field :email,              type: String, default: ''
  field :encrypted_password, type: String, default: ''
end
