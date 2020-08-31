Rails.application.routes.draw do

  resources :companies do
    resources :users, :only => [:new, :create, :index, :show, :destroy]
  end

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
  devise_scope :user do
    get 'users/:id/edit' => 'users/registrations#edit', as: :edit_other_user_registration
    match 'users/:id', to: 'users/registrations#update', via: [:patch, :put], as: :other_user_registration
  end
  
  resources :leads do
    resources :steps
  end
  
end
