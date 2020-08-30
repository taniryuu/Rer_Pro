class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  # ログインしているユーザーがいる企業の社員全員取得
  def set_members
    @users = current_user.company_of_user
  end

  # devise関連
  # ログイン時のリダイレクト先
  def after_sign_in_path_for(resource)
    if current_user
      user_path(resource)
    else
      root_path
    end
  end

  # ログアウト時のリダイレクト先
  def after_sign_out_path_for(resource)
    root_path
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :login_id, :superior, :admin, :superior_id, :company_id])
      devise_parameter_sanitizer.permit(:sign_in, keys: [:login_id])
    end
end
