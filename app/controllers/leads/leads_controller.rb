class Leads::LeadsController < Leads::ApplicationController
  # オブジェクトの準備
  before_action :set_lead_and_user, except: %i(index new create)
  # フィルター（アクセス権限）
  before_action :only_same_company_id?, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :only_superior_user, only: %i(edit_user_id update_user_id)
  before_action :correct_or_admin_user, only: %i(destroy)

  # GET /leads
  # GET /leads.json
  def index
    @users = []
    User.where(company_id: current_user.company_id).each do |user|
      @users.push(["#{user.name}", user.id])
    end
    user_ids_all = User.where(company_id: current_user.company_id).pluck(:id)
    user_ids = params[:user_searchword].present? ? params[:user_searchword] : user_ids_all
    params_sort = params[:sort].present? ? params[:sort] : "created_date desc"
    @leads = Lead.where(user_id: user_ids)
                  .search("room_name", params[:room_searchword])
                  .search("customer_name", params[:customer_searchword])
                  .order(params_sort)
    case leads_count = @leads.count
    when 0
      flash.now[:danger] = "該当する案件はありません。検索条件を見直しください。"
    when Lead.where(user_id: user_ids_all).count
      flash.now[:success] = "全件表示中（全#{leads_count}件）"
    else
      flash.now[:success] = "#{leads_count}件ヒットしました。"
    end
    @leads = @leads.page(params[:page])
  end

  # GET /leads/1
  # GET /leads/1.json
  def show
  end

  # GET /leads/new
  def new
    @lead = current_user.leads.new
  end

  # GET /leads/1/edit
  def edit
  end

  # GET /leads/1/edit_user_id
  def edit_user_id
  end

  # POST /leads
  # POST /leads.json
  def create
    @lead = current_user.leads.new(lead_params)
    respond_to do |format|
      if @lead.save && update_steps_rate(@lead)
        format.html { redirect_to new_lead_step_path(@lead), notice: '案件を作成しました。引き続き進捗を登録してください。' }
        format.json { render :show, status: :created, location: @lead }
      else
        format.html { render :new }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /leads/1
  # PATCH/PUT /leads/1.json
  def update
    respond_to do |format|
      if @lead.update(lead_params) && update_steps_rate(@lead)
        format.html { redirect_to @lead, notice: 'Lead was successfully updated.' }
        format.json { render :show, status: :ok, location: @lead }
      else
        format.html { render :edit }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # 案件の担当者を変更（上長のみ）
  def update_user_id
    respond_to do |format|
      if @lead.update(lead_params_only_user_id)
        format.html { redirect_to @lead, notice: 'User of Lead was successfully updated.' }
        format.json { render :show, status: :ok, location: @lead }
      else
        format.html { render :edit }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /leads/1
  # DELETE /leads/1.json
  def destroy
    @lead.destroy
    respond_to do |format|
      format.html { redirect_to leads_url, notice: 'Lead was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lead_and_user
      @lead = Lead.find(params[:id])
      @user = User.find(@lead.user_id)
    end
    
    # Only allow a list of trusted parameters through.
    def lead_params
      params.require(:lead).permit(:created_date, :completed_date, :customer_name, :room_name, :room_num, :template, :template_name, :memo, :status, :notice_created, :notice_change_limit, :scheduled_resident_date, :scheduled_payment_date, :scheduled_contract_date, :steps_rate)
    end
    
    # Only allow user_id of trusted parameters.
    def lead_params_only_user_id
      params.require(:lead).permit(:user_id)
    end
    
end
