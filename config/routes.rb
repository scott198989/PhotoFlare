Rails.application.routes.draw do
  resources :posts
  devise_for :users

  # Stories
  resources :stories, only: [:index, :show, :create, :destroy] do
    member do
      post :view, to: 'stories#mark_viewed'
    end
    collection do
      get 'user/:user_id', to: 'stories#user_stories', as: :user
    end
  end

  # Direct Messaging
  resources :conversations, only: [:index, :show, :create] do
    resources :messages, only: [:create]
  end

  # Explore
  get 'explore', to: 'explore#index'
  get 'explore/search', to: 'explore#search', as: :explore_search
  get 'explore/hashtag/:tag', to: 'explore#hashtag', as: :explore_hashtag

  # Notifications
  resources :notifications, only: [:index] do
    collection do
      post :mark_all_as_read
    end
    member do
      post :mark_as_read
    end
  end

  # Action Cable
  mount ActionCable.server => '/cable'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"

  post "toggle_like", to:  "likes#toggle_like", as: :toggle_like

  resources :comments, only: [:create, :destroy]
  resources :users, only: [:show, :index]

  post "follow", to: 'follows#follow', as: :follow
  delete 'unfollow', to: 'follows#unfollow', as: :unfollow
  delete 'cancel_request', to: 'follows#cancel_request', as: :cancel_request

  post 'accept_follow', to: 'follows#accept_follow', as: :accept_follow
  delete 'decline_follow', to: 'follows#decline_follow', as: :decline_follow

end
