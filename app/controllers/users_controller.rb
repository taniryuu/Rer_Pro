class UsersController < Users::ApplicationController
  before_action :set_user, only: %i(show edit destroy)
  before_action :set_members, only: %i(index edit)
  before_action :set_company_id, only: :new

  def index
  end

  def new
    @user = User.new
  end

  def create
    if @user.create!(user_params)
      flash[:success] = "登録に成功しました"
      log_in @user
      redirect_to user_url
    else
      flash[:danger] = "登録に失敗しました"
    end
  end

  def show
  end

  def edit
  end

  def destroy
# 削除には@userが未完了の案件を持っていないこと
    @user.destroy ? flash[:success] : flash[:danger]
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :login_id, :superior, :email, :password, :password_confirmation, :company_id, :superior_id)
    end
end
