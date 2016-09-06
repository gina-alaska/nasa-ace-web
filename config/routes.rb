Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  resources :workspaces
  resources :datasets
  get 'welcome/index'

  root to: 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
