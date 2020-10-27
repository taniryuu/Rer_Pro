class UsersController < NotificationsController
  include UsersHelper

  # オブジェクトの準備
  before_action :set_user, only: %i(show)
  before_action :set_users, only: %i(index show)
  before_action :notice, only: :show
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
    # 入居予定日に近づいてる案件の通知
    @mystep_limit_notices = []
    @user.leads.in_progress.each do |lead|
      if lead.steps.todo.where("scheduled_complete_date <= ?", @user.limit_date).present?
        @mystep_limit_notices.push(lead)
      end
    end
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
