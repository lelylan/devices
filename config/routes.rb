Devices::Application.routes.draw do
  resources :devices, defaults: {format: 'json'} do
    resources :histories, only: ['index', 'show']
    member do
      put   'functions'   => 'functions#update'
      put    'properties' => 'properties#update'
      put    'physical'  => 'physicals#update'
      delete 'physical'  => 'physicals#destroy'
    end
  end
end
