# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {sessions: 'devise/cas_sessions'}
  mount ActionCable.server => '/cable'

  resources :workspaces do
    resources :views do
      member do
        get 'duplicate'
        get 'available_layers'
      end

      resources :view_layers
    end
  end

  devise_scope :user do
    get '/logout',  :to => 'devise/cas_sessions#destroy'
  end
  
  resources :datasets
  resources :layers
  resources :categories

  get 'welcome/index'
  root to: 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
