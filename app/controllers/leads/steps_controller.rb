class Leads::StepsController < Leads::ApplicationController
  # オブジェクトの準備
  before_action :set_step, except: %i(index new create)
  before_action :set_lead_and_user_by_lead_id, only: %i(index new create)
  before_action :set_steps, only: %i(show)
  # フィルター（アクセス権限）
  before_action :only_same_company_id?
  before_action :correct_user, except: %i(index show)
  # 後処理
  after_action :sort_order, only: %i(destroy index)


  # GET /steps
  # GET /steps.json
  def index
    @steps = @lead.steps.all.ord
  end

  # GET /steps/1
  # GET /steps/1.json
  def show
    # タスクステータスが「未」のリスト
    @tasks = @step.tasks.not_yet.order(:scheduled_complete_date)
    # タスクステータスが「完了」のリスト
    @completed_tasks_array = @step.tasks.completed.order(:completed_date)
    # タスクステータスが「中止」のリスト
    @canceled_tasks_array = @step.tasks.canceled.order(:canceled_date)
    @task = @step.tasks.new
  end

  # GET /steps/new
  def new
    @step = @lead.steps.new
    @completed_step = Step.find(params[:completed_id]) if params[:completed_id].present?
    @start_lead_flag = true if params[:start_lead_flag].present?
  end

  # GET /steps/1/edit
  def edit
  end

  # POST /steps
  # POST /steps.json
  def create
    @step = @lead.steps.new(step_params)
    if save_and_errors_of(@lead, @step).blank?
      flash[:success] = "#{flash[:success]}#{@step.name}を作成しました。"
      redirect_to @step
    else
      flash.delete(:success)
      flash.now[:danger] = "#{@lead.errors.full_messages.first}" if @lead.errors.present?
      flash.now[:danger] = "#{flash.now[:danger]}#{@completed_step.errors.full_messages.first}" if @completed_step.present? && @completed_step.errors.present?
      render :new
    end
  end

  # PATCH/PUT /steps/1
  # PATCH/PUT /steps/1.json
  def update
    if update_and_errors_of(@lead, @step).blank?
      flash[:success] = "#{flash[:success]}#{@step.name}を更新しました。"
      redirect_to @step
    else
      flash.delete(:success)
      flash.now[:danger] = @lead.errors.full_messages.first if @lead.errors.present?
      render :edit
    end
  end

  # DELETE /steps/1
  # DELETE /steps/1.json
  def destroy
    destroy_step(@lead, @step)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_step
      @step = Step.find(params[:id])
      @lead = Lead.find(@step.lead_id)
      @user = User.find(@lead.user_id)
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_lead_and_user_by_lead_id
      @lead = Lead.find(params[:lead_id])
      @user = User.find(@lead.user_id)
    end

    # Only allow a list of trusted parameters through.
    def step_params
      params.require(:step).permit(:lead_id, :name, :memo, :status, :order, :scheduled_complete_date, :completed_date, :completed_tasks_rate)
    end
    
    # クリエイト処理
    def save_and_errors_of(lead, step)
      errors = []
      ActiveRecord::Base.transaction do
        # 作成処理（バリデーションなし）
        prepare_order(lead.steps.count + 1, step.order)
        errors << step.errors.full_messages unless step.save
        # 完了する進捗がある場合の処理
        if params[:step][:completed_id].present?
          @completed_step = Step.find(params[:step][:completed_id]) # 完了処理に失敗したら、改めてオブジェクトを渡す必要があるのでインスタンス変数を使用。
          errors << @completed_step.errors.full_messages unless complete_step(lead, @completed_step, @completed_step.latest_date)
        end
        # 案件を再開する場合の処理
        if params[:step][:start_lead_flag] == "true"
          @start_lead_flag = true
          errors << lead.errors.full_messages unless start_lead(lead)
        end
        # 矛盾を解消
        check_status_inactive_or_not(step)
        check_status_completed_or_not(lead, step)
        # バリデーション確認
        errors << lead.errors.full_messages if lead.invalid?(:check_steps_status)
        errors << step.errors.full_messages if step.invalid?(:check_order)
        raise ActiveRecord::Rollback if errors.present?
      end
      errors.presence || nil
    end
    
    # アップデート処理
    def update_and_errors_of(lead, step)
      errors = []
      ActiveRecord::Base.transaction do
        # 更新処理（バリデーションなし）
        prepare_order(step.order, params[:step][:order].to_i)
        step.update(step_params)
        lead.update_attribute(:notice_change_limit, true) if step.saved_change_to_scheduled_complete_date?
        # 矛盾を解消
        check_status_inactive_or_not(step)
        check_status_completed_or_not(lead, step)
        # バリデーション確認
        errors << lead.errors.full_messages if lead.invalid?(:check_steps_status)
        errors << step.errors.full_messages if step.invalid?(:check_order)
        raise ActiveRecord::Rollback if errors.present?
      end
      errors.presence || nil
    end
    
    # 〇番(pre_order)だったデータを避難し、×番(new_order)を空けておく処理
    def prepare_order(pre_order, new_order)
      unless pre_order == new_order || pre_order.blank? || new_order.blank?
        # Updateの場合、pre_orderを最大値+1に一時避難
        @lead.steps.find_by(order: pre_order).update_attribute(:order, @lead.steps.count + 1) unless @step.new_record?
        if pre_order < new_order
          # (pre_order + 1)..new_orderを前にずらす処理
          ((pre_order + 1)..new_order).each do |order_num|
            back_step = @lead.steps.find_by(order: order_num)
            back_step.update_attribute(:order, order_num - 1)
          end
        else
          # new_order..(pre_order - 1)の順番を後ろにずらす処理
          (new_order..(pre_order - 1)).reverse_each do |order_num|
            next_step = @lead.steps.find_by(order: order_num)
            next_step.update_attribute(:order, order_num + 1)
          end
        end
      end
    end
    
    # 順番をチェックし、空があったら詰める処理
    def sort_order
      if @lead.steps.find_by(order: @lead.steps.count + 1).present?
        (1..@lead.steps.count).each do |order_num|
          if @lead.steps.find_by(order: order_num).blank?
            step = @lead.steps.find_by(order: order_num + 1)
            step.update_attribute(:order, order_num)
          end
        end
      end
    end
    
end
