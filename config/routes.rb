Devices::Application.routes.draw do
  resources :devices, defaults: { format: 'json' } do
    member do
      put    'properties' => 'properties#update'
      put    'functions'  => 'functions#update'
      get    'privates'   => 'devices#privates'
      post   'accesses'   => 'accesses#create'
    end
  end

  resources :histories,    defaults: { format: 'json' }, only: %w(index show)
  resources :consumptions, defaults: { format: 'json' }
  resources :activations,  defaults: { format: 'json' }, only: %w(create destroy)
end
