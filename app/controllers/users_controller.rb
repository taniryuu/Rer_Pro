class UsersController < Users::ApplicationController
  include UsersHelper

  # オブジェクトの準備
  before_action :set_user, only: %i(show)
  before_action :set_members, only: %i(index)
  # アクセス制限
  before_action :current_user_admin?, only: %i(new create destroy)

  DELETE_COMMAND = "Delete".freeze

  def index
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "登録に成功しました"
      redirect_to users_url
    else
      render :new
    end
  end

  def show
  end

  def destroy
    @user = User.find_by(id: params[:command])
    if @user.present? && delete_judgment(@user)
      if DELETE_COMMAND == params[:input_delete]
        if @user.leads.find_by(completed_date: "").blank?
          @user.destroy
          flash[:success] = "成功しました。"
        else
          flash[:danger] = "未完了の案件を担当しています。別の担当者に変えてください。"
        end
      else
        flash[:danger] = "正しく入力してください。"
      end
    else
      flash[:danger] = "存在しないユーザーに対する操作を確認しました。"
    end
    redirect_to users_url
  end

  private

    # ユーザーIDを取得し識別
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :login_id, :superior, :email, :password, :password_confirmation, :company_id, :superior_id)
    end
end
