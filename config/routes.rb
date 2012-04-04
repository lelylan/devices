Devices::Application.routes.draw do
  resources :devices, defaults: {format: 'json'} do
    member do
      put   'functions'   => 'functions#update'
      put    'properties' => 'properties#update'
      put    'physical'   => 'physicals#update'
      delete 'physical'   => 'physicals#destroy'
      get    'histories'  => 'histories#index'
    end
  end

  resources :histories, defaults: {format: 'json'}, only: 'show'
end
