Rails.application.routes.draw do

  # 会社フォルダ群 company関連
  resources :companies
  
  # ユーザーフォルダ群（Users::ApplicationControllerを継承）user, devise関連
  devise_for :users, skip: [:sessions, :registrations], controllers: {
    registrations: "users/registrations"
  }
  resources :users, :only => [:index, :new, :create, :show, :destroy]
  devise_scope :user do
    root :to => "devise/sessions#new"
    post 'login' => 'devise/sessions#create', as: :user_session
    delete 'logout' => 'devise/sessions#destroy', as: :destroy_user_session
    get 'users/:id/edit' => 'users/registrations#edit', as: :edit_other_user_registration
    match 'users/:id', to: 'users/registrations#update', via: [:patch, :put], as: :other_user_registration
  end
  
  # 案件フォルダ群（Leads::ApplicationControllerを継承）lead, step, task関連
  resources :leads, shallow: true, module: 'leads' do
    member do
      get 'edit_user_id'
      patch 'update_user_id'
    end
    resources :steps do
      member do
        get 'edit_status' => 'steps_statuses#edit', as: :edit_statuses_of
        patch 'complete/:completed_id' => 'steps_statuses#complete', as: :complete
        patch 'start' => 'steps_statuses#start', as: :start
        patch 'cancel' => 'steps_statuses#cancel', as: :cancel
      end
      member do
        get 'tasks/edit_add_delete_list'
        post 'tasks/update_add_delete_list'
        get 'tasks/edit_continue_or_destroy_step'
        post 'tasks/update_continue_or_destroy_step'
        get 'tasks/edit_complete_or_continue_step'
        post 'tasks/update_complete_or_continue_step'
        get 'tasks/edit_change_status_or_complete_task'
        post 'tasks/update_change_status_or_complete_task'
      end
      resources :tasks do
        member do
          get 'add_canceled_list'
          get 'edit_revive_from_canceled_list'
          patch 'update_revive_from_canceled_list'
        end
      end
    end
  end
end
