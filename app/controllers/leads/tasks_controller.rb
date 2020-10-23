class Leads::TasksController < Leads::ApplicationController
  # オブジェクトの準備
  before_action :set_task, only: %i(show edit update destroy add_canceled_list 
                                    edit_revive_from_canceled_list update_revive_from_canceled_list)
  before_action :set_step, only: %i(index new create)
  before_action :set_step_by_id, only: [:edit_add_delete_list, :update_add_delete_list, :edit_continue_or_destroy_step,
                                        :edit_complete_or_continue_step, :edit_change_status_or_complete_task, :complete_all_tasks]
  before_action :set_steps, only: :edit_complete_or_continue_step
  # アクセス制限
  before_action :correct_user, except: %i(index show)


  def index
    # タスクステータスが「未」のリスト
    @tasks = @step.tasks.not_yet.order(:scheduled_complete_date)
    # タスクステータスが「完了」のリスト
    @completed_tasks = @step.tasks.completed.order(:completed_date)
    # タスクステータスが「中止」のリスト
    @canceled_tasks = @step.tasks.canceled.order(:canceled_date)
    @task = @step.tasks.new
  end

  def show
  end

  def new
    @task = @step.tasks.new
  end

  def edit
  end

  def create
    @task = Task.new(task_params)
    if prohibit_future(@task.scheduled_complete_date)
      flash[:danger] = "完了予定日に過去の日付を入力しようとしています。"
    end
    if @task.save
      update_completed_tasks_rate(@step)
      check_status_and_redirect_to(@step, @step)
    else
      render :new 
    end
  end


  def update
    if @task.update(task_params) 
      update_completed_tasks_rate(@step)
      # 完了日が空なら今日の日付を入れる
      @task.date_blank_then_today("completed")
      # 中止にした日が空なら今日の日付を入れる
      @task.date_blank_then_today("canceled")
      if prohibit_future(@task.scheduled_complete_date) && prohibit_future(@task.completed_date)
        flash[:danger] = "完了予定日と完了日に過去の日付を入力しようとしています。"
      elsif prohibit_future(@task.scheduled_complete_date)
        flash[:danger] = "完了予定日に過去の日付を入力しようとしています。"
      elsif prohibit_future(@task.completed_date)
        flash[:danger] = "完了日に過去の日付を入力しようとしています。"
      end
      check_status_and_redirect_to(@step, @step)
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    update_completed_tasks_rate(@step)
    check_status_and_redirect_to(@step, @step)
  end

  # 「To Do リスト」にチェックを入れて「更新」ボタンを押したときに実行されるアクション
  def edit_add_delete_list
  end

  # 「To Do リスト」にチェックを入れて「完了」リストに入れる処理
  def update_add_delete_list
    checkbox_array = []
    checkbox_array = params[:task][:delete_task]
    n = checkbox_array.size
    # チェックボックスの配列で"true"の前に差し込まれた"false"を削除している
    n.times do |i|
      if checkbox_array[i] == "true"
        checkbox_array.delete_at(i - 1)
      end
    end
    n1 = checkbox_array.size
    i2 = 0
    # タスクステータスが「完了」のリスト
    @completed_tasks = @step.tasks.completed.order(:completed_date)

    n1.times do |i1|
      if checkbox_array[i1] == "true"
        # (i1-i2)番目のタスクステータスが「未」のタスクの１個の要素からなるActiveRecordAsociation?Relationがdeleted_tasks(配列のようなもの)
        # 下でタスクステータスを「未」から「完了」に変えているのでi2(checkbox=="true"の数)だけi1から引いている
        deleted_tasks = @step.tasks.not_yet.order(:scheduled_complete_date).limit(1).offset(i1 - i2)
        i2 += 1
        # 1個の要素からなるActiveRecordAsociation?Relationから1個の要素deleted_taskを取り出して
        # タスクステータスを「完了」、「完了日」を本日に設定している
        deleted_tasks.each do |deleted_task|
          deleted_task.update_attribute(:status, "completed")
          update_completed_tasks_rate(@step)
          deleted_task.update_attribute(:completed_date, "#{Date.current}") if deleted_task.completed_date.blank?
        end
      end
    end
    check_status_and_redirect_to(@step, @step)
  end

  # 「To Do リスト」で中止ボタンを押して「中止」リストに入れる処理
  def add_canceled_list
    @task.update_attribute(:status, "canceled")
    update_completed_tasks_rate(@step)
    @task.update_attribute(:canceled_date, "#{Date.current}") if @task.canceled_date.blank?
    check_status_and_redirect_to(@step, @step)
  end

  # 復活ボタンを押したときに実行されるアクション
  def edit_revive_from_canceled_list
  end

  # 復活ボタンを押した画面から更新ボタンを押した後の処理
  def update_revive_from_canceled_list
    if @task.update_attributes(revive_from_canceled_list_params)
      if prohibit_future(@task.scheduled_complete_date)
        flash[:danger] = "完了予定日に過去の日付を入力しようとしています。"
      end
      @task.update_attribute(:status, "not_yet")
      update_completed_tasks_rate(@step)
    else
      flash[:danger] = "#{@task.name}の更新は失敗しました。" + @task.errors.full_messages[0]
    end
    check_status_and_redirect_to(@step, @step)
  end

  def edit_continue_or_destroy_step
  end


  def edit_complete_or_continue_step
  end


  def edit_change_status_or_complete_task
  end

  # 「未」のタスクをすべて「完了」とする
  def complete_all_tasks
    #現在の進捗の「未」のタスクをすべて「完了」とし、「完了日」を本日とし、その後complete_or_continueのurlへ飛ぶ
    errors = []
    ActiveRecord::Base.transaction do
      errors << @step.errors.full_messages unless @step.tasks.not_yet.update_all(status: "completed", completed_date: "#{Date.current}")
      update_completed_tasks_rate(@step)
      raise ActiveRecord::Rollback if errors.present?
    end
    redirect_to check_status_and_get_url(@step, @step)
  end


  private
    def set_task
      @task = Task.find(params[:id])
      @step = Step.find(@task.step_id)
      @lead = Lead.find(@step.lead_id)
      @user = User.find(@lead.user_id)
    end
 
    def set_step
      @step = Step.find(params[:step_id])
      @lead = Lead.find(@step.lead_id)
      @user = User.find(@lead.user_id)
    end

    def set_step_by_id
      @step = Step.find(params[:id])
      @lead = Lead.find(@step.lead_id)
      @user = User.find(@lead.user_id)
    end

    def task_params
      params.require(:task).permit(:step_id, :name, :memo, :status, :scheduled_complete_date, :completed_date, :canceled_date)
    end

    def revive_from_canceled_list_params
      params.require(:task).permit(:scheduled_complete_date)
    end
    
    # day空でなく、今日より前ならtrue
    def prohibit_future(day)
      day.blank? ? false : Date.parse(day) < Date.current
    end

    def create_new_task_step_in_progress(lead, step)
      Task.create!(step_id: step.id ,name: "new_task", status: "not_yet", scheduled_complete_date: "#{Date.current}")
      redirect_to step_statuses_start_step_url(@step)
    end
end
