class Leads::LeadsController < Leads::ApplicationController
  # オブジェクトの準備
  before_action :set_lead_and_user, except: %i(index new create)
  before_action :set_users, only: %i(index edit_user_id)
  before_action ->{
    set_leads(Lead.where.not(status: "template"))
  }, only: %i(index)
  # フィルター（アクセス権限）
  before_action :only_same_company_id?, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :only_superior_user, only: %i(edit_user_id update_user_id)
  before_action :correct_or_admin_user, only: %i(destroy)

  # GET /leads
  # GET /leads.json
  def index
  end

  # GET /leads/1
  # GET /leads/1.json
  def show
  end

  # GET /leads/new
  def new
    @lead = current_user.leads.new
    set_template_lead_and_date_difference(params[:template_id])
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
    if save_lead_errors(@lead).blank?
      flash[:success] = "案件を作成しました。#{flash[:success]}"
      redirect_to step_url(working_step_in(@lead))
    else
      set_template_lead_and_date_difference(params[:lead][:template_id])
      flash.delete(:success)
      flash.now[:danger] = "#{@lead.errors.full_messages.first}" if @lead.errors.present?
      render :new
    end
  end

  # PATCH/PUT /leads/1
  # PATCH/PUT /leads/1.json
  def update
    respond_to do |format|
      if @lead.update(lead_params) && update_steps_rate(@lead)
        check_status_inactive_or_not(@lead)
        check_status_completed_or_not(@lead, nil)
        @lead.update_attribute(:notice_change_limit, true) if @lead.saved_change_to_scheduled_resident_date? || @lead.saved_change_to_scheduled_payment_date?
        format.html { redirect_to step_path(working_step_in(@lead)), notice: 'Lead was successfully updated.' }
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
    
    def set_template_lead_and_date_difference(template_id)
      if template_id.present?
        @template_lead = Lead.find(template_id)
        @date_difference = (Date.current - Date.parse(@template_lead.created_date)).to_i
        flash.now[:info] = "テンプレート「#{@template_lead.template_name}」から新しく案件を作成します。"
      end
    end
    
    # Only allow a list of trusted parameters through.
    def lead_params
      params.require(:lead).permit(:created_date, :completed_date, :customer_name, :room_name, :room_num, :template, :template_name, :memo, :status, :notice_created, :notice_change_limit, :scheduled_resident_date, :scheduled_payment_date, :scheduled_contract_date, :steps_rate)
    end
    
    # Only allow user_id of trusted parameters.
    def lead_params_only_user_id
      params.require(:lead).permit(:user_id)
    end
    
    # クリエイト処理
    def save_lead_errors(lead)
      errors = []
      ActiveRecord::Base.transaction do
        # 作成処理（バリデーションなし）
        if lead.save
          # 必要な進捗(デフォルト)を作成
          if params[:lead][:template_id].present?
            set_template_lead_and_date_difference(params[:lead][:template_id])
            @template_lead.steps.all.each do |step|
              new_step = Step.create!(
                lead_id: lead.id,
                name: step.name,
                status: "in_progress",
                order: step.order,
                scheduled_complete_date: (Date.parse(step.scheduled_complete_date) + @date_difference).to_s,
              )
              step.tasks.all.each do |task|
                Task.create!(
                  step_id: new_step.id,
                  name: task.name,
                  status: task.status,
                  scheduled_complete_date: (Date.parse(task.scheduled_complete_date) + @date_difference).to_s,
                )
              end
            end
            flash[:success] = "テンプレート「#{@template_lead.template_name}」の進捗及びタスクをコピーしました。"
          else
            # 将来的には、上長の設定したテンプレートの進捗が自動生成されるようにしたい。
            # （ある程度決まったプロセスなのに一から進捗をつくるのはUXとして非現実的。）↓は仮。
            lead.steps.create!(
              name: "進捗(仮)",
              status: 2,
              order: 1,
              scheduled_complete_date: "#{Date.current}",
            )
          end
    
          # 矛盾を解消
          check_status_inactive_or_not(lead)
          check_status_completed_or_not(lead, nil)
          # バリデーション確認
          errors << lead.errors.full_messages if lead.invalid?(:check_steps_status)
        else
          errors << lead.errors.full_messages
        end
        raise ActiveRecord::Rollback if errors.present?
      end
      errors.presence || nil
    end
    
end
