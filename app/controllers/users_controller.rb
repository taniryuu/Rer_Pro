class UsersController < ApplicationController
  before_action :set_user, only: %i(show edit update destroy)
  before_action :set_members, only: %i(index edit)

  def index
  end

  def new
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      # flashメッセ
      redirect_to users_url
    else
      # flashメッセ
      render :edit
    end
  end

  def destroy
# 削除には@userが未完了の案件を持っていないこと
    @user.destroy ? flash[success] : flash[:danger]
    redirect_to users_url
  end

  private
  
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:login_id, :name, :superior, :admin, :status, :superior_id, :email)
  end
end
