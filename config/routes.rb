Rails.application.routes.draw do

  # 会社フォルダ群 company関連
  resources :companies
  
  # ユーザーフォルダ群（Users::ApplicationControllerを継承）user, devise関連
  devise_for :users, skip: [:sessions, :registrations], controllers: { registrations: "users/registrations" }
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
      patch 'start/:step_id' => 'leads_statuses#start', as: :start
      patch 'cancel' => 'leads_statuses#cancel', as: :cancel
    end
    resources :steps do
      member do
        patch 'complete/:completed_id' => 'steps_statuses#complete', as: :complete
        patch 'start' => 'steps_statuses#start', as: :start
        patch 'cancel' => 'steps_statuses#cancel', as: :cancel
        patch 'statuses_make_step_not_yet'
       # patch 'statuses_make_all_not_yet_tasks_completed'
      end
      resources :tasks do
        member do
          get 'add_canceled_list'
          get 'edit_revive_from_canceled_list'
          patch 'update_revive_from_canceled_list'
          get 'edit_add_delete_list'
          post 'update_add_delete_list'
          get 'edit_continue_or_destroy_step'
          get 'edit_complete_or_continue_step'
          get 'edit_change_status_or_complete_task'
          patch 'statuses_make_all_not_yet_tasks_completed'
        end
      end
    end
  end
end
