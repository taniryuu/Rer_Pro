Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:index, :show] do
    resources :leads
  end
  resources :companies
end
