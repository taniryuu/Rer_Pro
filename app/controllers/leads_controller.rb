class LeadsController < Leads::ApplicationController
  # オブジェクトの準備
  before_action :set_lead_and_user, except: %i(index new create)
  # フィルター（アクセス権限）
  before_action :same_company_id, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :only_superior_user, only: %i(edit_user_id update_user_id)
  before_action :correct_or_admin_user, only: %i(destroy)

  # GET /leads
  # GET /leads.json
  def index
#    @leads = Lead.where(user_id: Company.find(current_user.company_id).users.pluck(:id)) # SQL発行回数４回
    @leads = Lead.where(user_id: User.where(company_id: current_user.company_id).pluck(:id)) # SQL発行回数３回でこちらを採用。
  end

  # GET /leads/1
  # GET /leads/1.json
  def show
    if params[:completed_id].present?
      complete_step(@lead, Step.find(params[:completed_id]))
      complete_lead(@lead)
      flash.now[:success] = "全ての進捗が完了し、本案件は終了済となりました。おつかれさまでした。"
    end
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
        format.html { redirect_to @lead, notice: 'Lead was successfully created.' }
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

  # PATCH/PUT /leads/1/update_user_id
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
