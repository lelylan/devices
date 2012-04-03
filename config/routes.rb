Devices::Application.routes.draw do
  resources :devices, defaults: {format: 'json'} do
    member do
      put   'functions'   => 'functions#update'
      put    'properties' => 'properties#update'
      put    'physical'  => 'physicals#update'
      delete 'physical'  => 'physicals#destroy'
    end
  end
end
