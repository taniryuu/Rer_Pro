class Leads::StepsController < Leads::ApplicationController
  # オブジェクトの準備
  before_action :set_step, except: %i(index new create)
  before_action :set_lead_and_user_by_lead_id, only: %i(index new create)
  before_action :set_steps, only: %i(show)
  # フィルター（アクセス権限）
  before_action :only_same_company_id?
  before_action :correct_user, except: %i(index show change_limit_check)
  # 後処理
  # after_action :sort_order, only: %i(destroy index)


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
    @completed_tasks = @step.tasks.completed.order(:completed_date)
    # タスクステータスが「中止」のリスト
    @canceled_tasks = @step.tasks.canceled.order(:canceled_date)
    @task = @step.tasks.new
    $through_check_status = false
    @steps_notice_list = @lead.steps.where(notice_change_limit: true)
  end

  # GET /steps/new
  def new
    @step = @lead.steps.new
    @completed_step = Step.find(params[:completed_id]) if params[:completed_id].present?
    @start_lead_flag = true if params[:start_lead_flag].present?
    @task = Task.new
  end

  # GET /steps/1/edit
  def edit
    @task = Task.new
  end

  # POST /steps
  # POST /steps.json
  def create
    @step = @lead.steps.new(step_params)
    @task = @step.tasks.new(task_params)
    flash[:danger] = "#{flash[:danger]}タスクの完了予定日に過去の日付を入力しようとしています。" if prohibit_past(@task.scheduled_complete_date)
    flash[:danger] = "#{flash[:danger]}タスクの完了日に過去の日付を入力しようとしています。" if prohibit_past(@task.completed_date)
    if save_step_errors(@lead, @step).blank?
      flash[:success] = "#{flash[:success]}#{@step.name}を作成しました。"
      if params[:step][:status].present? && params[:step][:status] == "completed"
        flash[:danger] = "「完了」タスクが無い、進捗は「完了」ステータスで新規作成しようとしています。「完了」タスクを自動で生成しました。"
        scheduled_complete_date = params[:step][:scheduled_complete_date].present? ? params[:step][:scheduled_complete_date] : "#{Date.current}"
        Task.create!(step_id: @step.id ,name: "completed_task", status: "completed", scheduled_complete_date: scheduled_complete_date, completed_date: params[:step][:completed_date])
      end
      # 編集-完了から進捗を新規作成した場合
      @completed_step.present? ? check_status_and_redirect_to(@completed_step, @step, nil) : check_status_and_redirect_to(@step, @step, nil)
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
    @present_not_yet_tasks = @step.tasks.not_yet.present? ? true : false
    # タスク新規作成
    @task = @step.tasks.new(task_params)
    if update_step_errors(@lead, @step).blank?
      flash[:success] = "#{flash[:success]}#{@step.name}を更新しました。"
      check_status_and_redirect_to(@step, @step, nil)
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

  # 進捗を未にする
  def statuses_make_step_not_yet
    errors = []
    ActiveRecord::Base.transaction do
      errors << @step.errors.full_messages unless @step.update_attributes(status: "not_yet")
      update_steps_rate(@lead)
      errors << @lead.errors.full_messages if @lead.invalid?(:check_steps_status)
      raise ActiveRecord::Rollback if errors.present?
    end
    redirect_to check_status_and_get_url(@step, @step)
  end

  # Stepの期限変更通知をfalseに更新
  def change_limit_check
    if @user.superior_id == current_user.id
      @step.update(notice_change_limit: false)
      @lead.update(notice_change_limit: false) if @lead.steps.where(notice_change_limit: true).blank?
      flash[:success] = "確認しました。"
    else
      flash[:danger] = "確認処理に失敗しました。"
    end
    redirect_to @step
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

    def task_params
      params.require(:task).permit(:name, :memo, :status, :scheduled_complete_date, :completed_date, :canceled_date)
    end
    
    # クリエイト処理
    def save_step_errors(lead, step)
      errors = []
      ActiveRecord::Base.transaction do
        # 作成処理（バリデーションなし）
        prepare_order(lead.steps.count + 1, step.order)
        errors << step.errors.full_messages unless step.save
        flash[:danger] = "#{flash[:danger]}進捗の完了予定日に過去の日付を入力しようとしています。" if prohibit_past(step.scheduled_complete_date)
        flash[:danger] = "#{flash[:danger]}進捗の完了日に過去の日付を入力しようとしています。" if prohibit_past(step.completed_date)
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
        # stepが「未」または「完了」のときはtaskを作らない
        if step.status?("not_yet") || step.status?("completed")
          @task.destroy
        end
        # 矛盾を解消
        check_status_inactive_or_not(step)
        check_status_completed_or_not(lead, step)
        # バリデーション確認
        errors << lead.errors.full_messages if lead.invalid?(:check_steps_status)
        errors << step.errors.full_messages if step.invalid?(:check_order)
        errors << @task.errors.full_messages if @task.present? && @task.invalid?
        raise ActiveRecord::Rollback if errors.present?
      end
      errors.presence || nil
    end
    
    # アップデート処理
    def update_step_errors(lead, step)
      errors = []
      ActiveRecord::Base.transaction do
        # 更新処理（バリデーションなし）
        prepare_order(step.order, params[:step][:order].to_i)
        step.update(step_params)
        flash[:danger] = "#{flash[:danger]}進捗の完了予定日に過去の日付を入力しようとしています。" if prohibit_past(step.scheduled_complete_date)
        flash[:danger] = "#{flash[:danger]}進捗の完了日に過去の日付を入力しようとしています。" if prohibit_past(step.completed_date)
        lead.update_attribute(:notice_change_limit, true) if step.saved_change_to_scheduled_complete_date?
        #stepにタスクがすでにある場合作る必要が無く、stepが「未」または「完了」のときタスクがあればバリデーションに反するので削除する
        if @present_not_yet_tasks || step.status?("not_yet") || step.status?("completed")
          @task.destroy
        else
          flash[:danger] = "#{flash[:danger]}タスクの完了予定日に過去の日付を入力しようとしています。" if prohibit_past(@task.scheduled_complete_date)
          flash[:danger] = "#{flash[:danger]}タスクの完了日に過去の日付を入力しようとしています。" if prohibit_past(@task.completed_date)
        end
        # 矛盾を解消
        check_status_inactive_or_not(step)
        check_status_completed_or_not(lead, step)
        # バリデーション確認
        errors << lead.errors.full_messages if lead.invalid?(:check_steps_status)
        errors << step.errors.full_messages if step.invalid?(:check_order)
        errors << @task.errors.full_messages if @task.present? && @task.invalid?
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
end
