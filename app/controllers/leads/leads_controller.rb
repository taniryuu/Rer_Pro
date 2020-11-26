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
  def index
  end

  # GET /leads/1
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
  def update
    if update_lead_errors(@lead).blank?
      @lead.update_attribute(:notice_change_limit, true) if @lead.saved_change_to_scheduled_resident_date? || @lead.saved_change_to_scheduled_payment_date?
      flash[:success] = "案件を編集しました。#{flash[:success]}"
      redirect_to step_url(working_step_in(@lead))
    else
      flash.delete(:success)
      flash.now[:danger] = "#{@lead.errors.full_messages.first}" if @lead.errors.present?
      render :edit
    end
  end

  # 案件の担当者を変更（上長のみ）
  def update_user_id
    if @lead.update(lead_params_only_user_id)
      pre_user = User.find(@lead.user_id_before_last_save)
      new_user = User.find(@lead.user_id)
      update_lead_count(pre_user)
      update_lead_count(new_user)
      flash[:success] = "担当者を#{pre_user.name}から#{new_user.name}へ変更しました。#{flash[:success]}"
      redirect_to step_url(working_step_in(@lead))
    else
      render :edit_user_id
    end
  end
  
  # DELETE /leads/1
  # DELETE /leads/1.json
  def destroy
    @lead.destroy
    update_lead_count(@user)
    flash[:success] = "案件(#{@lead.customer_name}様/#{@lead.room_name}-#{@lead.room_num}号室)を削除しました。#{flash[:success]}"
    redirect_to leads_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lead_and_user
      @lead = Lead.find(params[:id])
      @user = User.find(@lead.user_id)
    end
    
    # template_idから変数を定義（@template_lead及び@date_difference）
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
              status: lead.status,
              order: 1,
              scheduled_complete_date: "#{Date.current}",
            )
          end
          # 矛盾を解消
          update_lead_count(current_user)
          check_status_template_or_not(lead)
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
    
    # アップデート処理
    def update_lead_errors(lead)
      errors = []
      ActiveRecord::Base.transaction do
        # 作成処理（バリデーションなし）
        lead.update(lead_params)
        # 矛盾を解消
        check_status_template_or_not(lead)
        check_status_inactive_or_not(lead)
        check_status_completed_or_not(lead, nil)
        # バリデーション確認
        errors << lead.errors.full_messages if lead.invalid?(:check_steps_status)
        raise ActiveRecord::Rollback if errors.present?
      end
      errors.presence || nil
    end

end
