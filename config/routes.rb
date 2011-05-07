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
    member do
      put    "functions" => "functions#update"
      post   "physical"  => "physicals#create"
      delete "physical"  => "physicals#destroy"
    end
  end

end
