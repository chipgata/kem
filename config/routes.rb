Rails.application.routes.draw do
  devise_for :users
  get 'welcome/index'
  resources :categories
  resources :endpoints
  resources :settings
  resources :profiles
  get 'endpoints/ping/:id', to: 'endpoints#ping'
  root 'welcome#index'
  mount ActionCable.server => '/cable'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
