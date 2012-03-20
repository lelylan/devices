Devices::Application.routes.draw do
  resources :devices, defaults: {format: 'json'} do
    member do
      put 'functions' => 'functions#update'
    end
  end
end
