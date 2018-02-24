Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root :to => "cars#index"
  resources :cars
  get "cars/:id", to: "cars/#show"
  get "redflag", to: "cars#redflag"
end
