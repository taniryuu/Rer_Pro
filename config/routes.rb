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
  
  resources :leads do
    member do
      get 'edit_user_id'
      patch 'update_user_id'
    end
    resources :steps do
      #member do
        #get 'tasks/edit_add_delte_list'
        #post 'tasks/update_add_delete_list'
      #end
      resources :tasks
    end

  end


  get '/leads/:lead_id/steps/:step_id/tasks/edit_add_delete_list/', to: 'tasks#edit_add_delete_list', as: 'tasks_edit_add_delete_list_lead_step'
  post '/leads/:lead_id/steps/:step_id/tasks/udate_add_delete_list', to: 'tasks#update_add_delete_list', as: 'tasks_update_add_delete_list_lead_step' 


end
