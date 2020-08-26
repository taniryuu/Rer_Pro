class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  def after_sign_in_path_for(resource)
    if current_user
      user_path(resource)
    else
      root_path
    end
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :login_id, :superior, :admin, :superior_id, :company_id])
      devise_parameter_sanitizer.permit(:sign_in, keys: [:login_id])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name, :superior, :admin, :superior_id])
    end
end
