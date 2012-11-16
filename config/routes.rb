Devices::Application.routes.draw do
  resources :devices, defaults: { format: 'json' } do
    member do
      put    'properties' => 'properties#update'
      put    'functions'  => 'functions#update'
      put    'physical'   => 'physicals#update'
      delete 'physical'   => 'physicals#destroy'
      get    'pending'    => 'pendings#show'
      get    'private'    => 'devices#private'
    end
  end

  resources :histories,    defaults: { format: 'json' }, only: %w(index show)
  resources :consumptions, defaults: { format: 'json' }
  resources :activations,  defaults: { format: 'json' }, only: %w(create destroy)
end
