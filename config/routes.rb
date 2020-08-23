Rails.application.routes.draw do
  devise_for :users
  resources :companies do
    resources :users
  end
  
  resources :leads
  
end
