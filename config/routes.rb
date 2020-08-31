Rails.application.routes.draw do

  resources :companies
  
  devise_scope :user do
    root :to => "devise/sessions#new"
    post 'login' => 'devise/sessions#create', as: :user_session
    delete 'logout' => 'devise/sessions#destroy', as: :destroy_user_session
    get 'users/sign_up' => 'users/registrations#new', as: :new_user_registration
    post 'users' => 'users/registrations#create', as: :user_registration
  end
  resources :companies
  devise_for :users, skip: [:sessions, :registrations], controllers: {
    registrations: "users/registrations"
  }
  resources :users, :only => [:index, :show, :destroy]
  devise_scope :user do
    get 'users/:id/edit' => 'users/registrations#edit', as: :edit_user
    patch 'users/:id/edit' => 'users/registrations#update'
  end
  
  resources :leads do
    resources :steps
  end
  
end
