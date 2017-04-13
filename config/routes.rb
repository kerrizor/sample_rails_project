Rails.application.routes.draw do
  resources :clearance_batches, only: [:index, :create, :new, :show]
  root to: "clearance_batches#index"
end
