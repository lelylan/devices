# Doorkiper configuration
Doorkeeper.configure do
  orm :mongoid
end

# Doorkeeper models extensions
Devices::Application.config.to_prepare do
  Doorkeeper::AccessToken.class_eval { store_in collection: :oauth_access_tokens, session: 'people' }
  Doorkeeper::AccessGrant.class_eval { store_in collection: :oauth_access_grants, session: 'people' }
  Doorkeeper::Application.class_eval { store_in collection: :oauth_access_applications, session: 'people' }
  Doorkeeper::AccessToken.class_eval { include Filterable }
end
