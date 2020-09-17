Rails.application.routes.draw do

  resources :companies do
    devise_scope :user do
      get 'users/sign_up' => 'users/registrations#new', as: :new_user_registration
      post 'users' => 'users/registrations#create', as: :user_registration
    end
  end

  
  devise_scope :user do
    root :to => "devise/sessions#new"
    post 'login' => 'devise/sessions#create', as: :user_session
    delete 'logout' => 'devise/sessions#destroy', as: :destroy_user_session
  end
  devise_for :users, skip: [:sessions, :registrations], controllers: {
    registrations: "users/registrations"
  }
  resources :users, :only => [:index, :new, :create, :show, :destroy]
  devise_scope :user do
    get 'users/:id/edit' => 'users/registrations#edit', as: :edit_other_user_registration
    match 'users/:id', to: 'users/registrations#update', via: [:patch, :put], as: :other_user_registration
  end
  
  resources :leads, shallow: true do
    member do
      get 'edit_user_id'
      patch 'update_user_id'
      patch 'complete_all_steps'
    end
    resources :steps do
      member do
        get 'edit_status' => 'steps/step_statuses#edit', as: :edit_statuses_of
        # patch 'complete' => 'steps/step_statuses#complete', as: :complete
        patch 'start' => 'steps/step_statuses#start', as: :start
        patch 'cancel' => 'steps/step_statuses#cancel', as: :cancel
      end
      member do
        get 'tasks/edit_add_delete_list'
        post 'tasks/update_add_delete_list'
        get 'tasks/edit_check_status_1'
        post 'tasks/update_check_status_1'
        get 'tasks/edit_check_status_2'
        post 'tasks/update_check_status_2'
        get 'tasks/edit_check_status_3'
        post 'tasks/update_check_status_3'
      end
      resources :tasks
    end

  end




end
