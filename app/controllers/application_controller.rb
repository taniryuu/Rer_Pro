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

  # @userが現在ログインしているユーザーである場合のみアクセス可
  def correct_user
    unless @user == current_user
      flash[:notice] = "他ユーザーの案件を操作しようとしています。それは不可の設定です。"
      redirect_to current_user
    end
  end

  # @userが同じ会社の上長のみアクセス可
  def only_superior_user
    unless current_user.superior? && @user.company_id == current_user.company_id
      flash[:notice] = "アクセスには上長権限が必要です。"
      redirect_to current_user
    end
  end

  # @userが同じ会社の管理者または現在ログインしているユーザーである場合のみアクセス可
  def correct_or_admin_user
    unless @user == current_user || (current_user.admin? && @user.company_id == current_user.company_id)
      flash[:notice] = "アクセスには本人または管理者権限が必要です。"
      redirect_to current_user
    end
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
