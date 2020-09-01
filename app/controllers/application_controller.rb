class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  # ユーザーIDを取得し識別
  def set_user
    @user = User.find(params[:id])
  end

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

  # 管理者かどうか識別し管理者以外ならtopに戻しflash表示
  def current_user_admin?
    unless current_user.admin? || user_signed_in?
      redirect_to root
      flash[:danger] = "アクセスが無効です。"
    end
  end
  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :login_id, :superior, :admin, :superior_id, :company_id])
      devise_parameter_sanitizer.permit(:sign_in, keys: [:login_id])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name, :superior, :superior_id, :email, :notified_num, :password, :password_confirmation, :current_password])
    end
end
