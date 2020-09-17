class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :current_user_admin?, only: %i(show edit update destroy)
  before_action :authenticate_user!, except: %i(new create)
  before_action :admin_company?, only: %i(index)
  before_action :same_company?, only: %i(show edit update destroy)

  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.all
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
    @user = User.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  # POST /companies.json
  def create
    begin
      @company = Company.new(company_params)
      @user = User.new(user_params)
      ActiveRecord::Base.transaction do
        @user[:company_id] = @company.id if @company.update(admin: false, status: "active")
        @user.save!
        sign_in @user
        flash[:success] = "新規作成に成功しました"
        redirect_to current_user
      end
    rescue
      render :new
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id]).id
    end

    # Only allow a list of trusted parameters through.
    def company_params
      params.require(:company).permit(:name)
    end

    def user_params
      params.require(:company).permit(user: [:name, :login_id, :email, :password, :password_confirmation, :admin, :superior])[:user]
    end

    def same_company?
      unless @company == Company.find(current_user.company_id)
        redirect_to current_user
        flash[:danger] = "無効なアクセスが確認されました。"
      end
    end

    # Companyに管理者権限がない場合のアクセス制限
    def admin_company?
      unless Company.find(current_user.company_id).admin?
        redirect_to root_url
        flash[:danger] = "無効なアクセスが確認されました。"
      end
    end
end
