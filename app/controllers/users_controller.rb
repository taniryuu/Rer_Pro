class UsersController < Users::ApplicationController
  before_action :set_user, only: %i(show destroy)
  before_action :set_members, only: %i(index)
  before_action :current_user_admin?, only: %i(new create destroy)

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
      flash.now[:danger] = "登録に失敗しました"
      render :new
    end
  end

  def show
  end

  def destroy
    $DELETE_COMMAND = "Delete".freeze
    @user = User.find(params[:command])
    if $DELETE_COMMAND == params[:input_delete]
      # 現在はユーザーの持ってる案件の完了日が空文字である場合がない場合に分岐させてます
      if @user.leads.find_by(completed_date: "").empty?
        flash[:success] = "成功しました" if @user.destroy
      else
        flash[:danger] = "未完了の案件を担当しています。別の担当者に変えてください"
      end
    else
      flash[:danger] = "正しく入力してください"
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
