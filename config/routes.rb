Devices::Application.routes.draw do
  resources :devices, defaults: {format: 'json'}
end
