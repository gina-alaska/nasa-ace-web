# frozen_string_literal: true
Rails.application.routes.draw do
  resources :view_layers
  resources :layers
  resources :categories
  mount ActionCable.server => '/cable'

  resources :workspaces do
    resources :views do
      member do
        get 'duplicate'
        get 'add_layer'
      end
    end
  end
  resources :datasets
  get 'welcome/index'

  root to: 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
