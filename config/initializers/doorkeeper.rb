# Doorkiper configuration
Doorkeeper.configure do
  orm :mongoid
end

# Doorkeeper models extensions
Devices::Application.config.to_prepare do
  Doorkeeper::AccessToken.class_eval { store_in session: 'people' }
  Doorkeeper::AccessGrant.class_eval { store_in session: 'people' }
  Doorkeeper::Application.class_eval { store_in session: 'people' }
  Doorkeeper::AccessToken.class_eval { include Scopable }
end
