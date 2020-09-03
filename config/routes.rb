Rails.application.routes.draw do

  get 'tasks/new'
  resources :steps


  resources :companies
  
  devise_scope :user do
    root :to => "devise/sessions#new"
    post 'login' => 'devise/sessions#create', as: :user_session
    delete 'logout' => 'devise/sessions#destroy', as: :destroy_user_session
    get 'users/sign_up' => 'users/registrations#new', as: :new_user_registration
    post 'users' => 'users/registrations#create', as: :user_registration
  end
  devise_for :users, skip: [:sessions, :registrations], controllers: {
    registrations: "users/registrations"
  }
  resources :users, :only => [:index, :show, :destroy]
  devise_scope :user do
    get 'users/:id/edit' => 'users/registrations#edit', as: :edit_other_user_registration
    match 'users/:id', to: 'users/registrations#update', via: [:patch, :put], as: :other_user_registration
  end
  
  resources :leads do
    member do
      get 'edit_user_id'
      patch 'update_user_id'
    end
    resources :steps do
      resources :tasks
    end

  end

  
end
