Devices::Application.routes.draw do
  resources :devices, defaults: {format: 'json'} do
    resources 'histories', only: 'index'
    resources 'consumptions', only: 'index'
    member do
      put   'functions'   => 'functions#update'
      put    'properties' => 'properties#update'
      put    'physical'   => 'physicals#update'
      delete 'physical'   => 'physicals#destroy'
      get    'histories'  => 'histories#index'
      get    'pending'    => 'pendings#show'
    end
  end

  resources :histories, defaults: {format: 'json'}, only: 'show'
  resources :consumptions, defaults: {format: 'json'}
end
