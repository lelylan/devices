Devices::Application.routes.draw do
<<<<<<< HEAD
  resources :devices, defaults: { format: 'json' } do
    resources 'histories', only: 'index'
    resources 'consumptions', only: 'index'
    member do
      put    'functions'  => 'functions#update'
      put    'properties' => 'properties#update'
      put    'physical'   => 'physicals#update'
      delete 'physical'   => 'physicals#destroy'
      get    'histories'  => 'histories#index'
      get    'pending'    => 'pendings#show'
    end
  end

  resources :histories, defaults: { format: 'json' }, only: 'show'
  resources :consumptions, defaults: { format: 'json' }
=======
  root to: "users#new"

  # Authentication
  get "logout" => "sessions#destroy", as: "logout"
  get "login"  => "sessions#new",     as: "login"
  get "signup" => "users#new",        as: "signup"

  resources :users
  resources :sessions

  # API Resources
  get 'devices/:device_id.png' => 'statuses#show', format: 'png'
  resources :devices, defaults: {format: 'json'} do
    resources :pendings, only: 'index'
    resources :histories, only: 'index'
    get 'status' => 'statuses#show'
    get 'consumptions' => 'consumptions#index'
    member do
      put    "functions"  => "functions#update"
      put    "properties" => "properties#update"
      post   "physical"   => "physicals#create"
      delete "physical"   => "physicals#destroy"
    end
  end

  resources :consumptions, except: 'update', defaults: {format: 'json'}
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
end
