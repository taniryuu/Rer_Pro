Rails.application.routes.draw do
  resources :steps
  resources :companies
  
  devise_scope :user do
    root :to => "devise/sessions#new"
    post 'login' => 'devise/sessions#create', as: :user_session
    delete 'logout' => 'devise/sessions#destroy', as: :destroy_user_session
  end
  devise_for :users, skip: [:sessions]
  resources :users, only: [:index, :show]
  
  resources :leads do
    resources :steps
  end
  
end
