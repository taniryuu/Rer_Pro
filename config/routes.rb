Rails.application.routes.draw do
  devise_scope :user do
    root :to => "devise/sessions#new"
    post 'login' => 'devise/sessions#create', as: :user_session
    delete 'logout' => 'devise/sessions#destroy', as: :destroy_user_session
  end
  devise_for :users, skip: [:sessions]
  resources :users, only: [:index, :show] do
    resources :leads
  end
  resources :companies
end
