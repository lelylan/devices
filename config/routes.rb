Devices::Application.routes.draw do
  root to: "users#new"

  # Authentication

  get "logout" => "sessions#destroy", as: "logout"
  get "login"  => "sessions#new",     as: "login"
  get "signup" => "users#new",        as: "signup"

  resources :users
  resources :sessions

  # API Resources

  resources :devices, defaults: {format: 'json'} do
    resources :pendings, only: 'index'
    resources :histories, only: 'index'
    get 'consumptions/instantaneous' => 'consumptions#index', type: 'instantaneous' 
    get 'consumptions/durational' => 'consumptions#index', type: 'durational'
    get 'consumptions' => 'consumptions#index'
    member do
      put    "functions"  => "functions#update"
      put    "properties" => "properties#update"
      post   "physical"   => "physicals#create"
      delete "physical"   => "physicals#destroy"
    end
  end

  get 'consumptions/instantaneous' => 'consumptions#index', defaults: {format: 'json'}, type: 'instantaneous' 
  get 'consumptions/durational' => 'consumptions#index', defaults: {format: 'json'}, type: 'durational'
  resources :consumptions, except: 'update', defaults: {format: 'json'}
end
