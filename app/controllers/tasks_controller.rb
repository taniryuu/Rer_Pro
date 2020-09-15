class TasksController < Leads::ApplicationController
  before_action :set_task, only: %i(show edit update destroy add_canceled_list edit_revive_from_canceled_list update_revive_from_canceled_list)
  #before_action :set_lead_and_user_by_lead_id, only: %i(index)
  before_action :set_step, only: %i(index new create)
  before_action :set_step_by_id, only: %i(edit_add_delete_list update_add_delete_list edit_check_status_1 update_check_status_1)
  before_action :correct_user, except: %i(index show)

  


  def index
    @tasks = @step.tasks.where(status: "not_yet").order(:scheduled_complete_date)
    @completed_tasks_array = @step.tasks.where(status: "completed").order(:completed_date)
    @canceled_tasks_array = @step.tasks.where(status: "canceled").order(:canceled_date)
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
    if day_is_older_than_now(@task.scheduled_complete_date)
      flash[:danger] = "完了予定日に過去の日付を入力しようとしています。"
    end
    respond_to do |format|
      if @task.save && update_completed_tasks_rate(@step)
        format.html { redirect_to step_tasks_path(@step), notice: 'Task was successfully created.' }
        format.json { render :show, status: :created, location: step_tasks_path(@step) }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @task.update(task_params) && update_completed_tasks_rate(@step)
        if @task.status == "completed" && @task.completed_date.blank?
          @task.update_attribute(:completed_date, Date.current.strftime("%Y-%m-%d"))
        elsif @task.status == "canceled" && @task.canceled_date.blank?
          @task.update_attribute(:canceled_date, Date.current.strftime("%Y-%m-%d"))
        end
        if day_is_older_than_now(@task.scheduled_complete_date) && day_is_older_than_now(@task.completed_date)
          flash[:danger] = "完了予定日と完了日に過去の日付を入力しようとしています。"
        elsif day_is_older_than_now(@task.scheduled_complete_date)
          flash[:danger] = "完了予定日に過去の日付を入力しようとしています。"
        elsif day_is_older_than_now(@task.completed_date)
          flash[:danger] = "完了日に過去の日付を入力しようとしています。"
        end
        format.html { redirect_to step_tasks_path(@step), notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: step_tasks_path(@step) }
      else
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @task.destroy
    update_completed_tasks_rate(@step)
    respond_to do |format|
      format.html { redirect_to step_tasks_path(@step), notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def edit_add_delete_list
  end

  def update_add_delete_list
    checkbox_array = []
    checkbox_array = params[:task][:delete_task]
    n = checkbox_array.size
    n.times do |i|
      if checkbox_array[i] == "true"
        checkbox_array.delete_at(i - 1)
      end
    end
    n1 = checkbox_array.size
    i2 = 0
    @completed_tasks_array = @step.tasks.where(status: "completed").order(:completed_date)

    n1.times do |i1|
      if checkbox_array[i1] == "true"
        deleted_tasks = @step.tasks.where(status: "not_yet").order(:scheduled_complete_date).limit(1).offset(i1 - i2)
        i2 += 1
        deleted_tasks.each do |deleted_task|
          deleted_task.update_attribute(:status, "completed")
          update_completed_tasks_rate(@step)
          deleted_task.update_attribute(:completed_date, Date.current.strftime("%Y-%m-%d"))
          
        end
      end
    end
    redirect_to step_tasks_url(@step)
  end

  def add_canceled_list
    @task.update_attribute(:status, "canceled")
    update_completed_tasks_rate(@step)
    @task.update_attribute(:canceled_date, Date.current.strftime("%Y-%m-%d"))
    check_status
  end

  def edit_revive_from_canceled_list
  end

  def update_revive_from_canceled_list
    if @task.update_attributes(revive_from_canceled_list_params) && update_completed_tasks_rate(@step)
      if day_is_older_than_now(@task.scheduled_complete_date)
        flash[:danger] = "完了予定日に過去の日付を入力しようとしています。"
      end
      @task.update_attribute(:status, "not_yet")
    else
      flash[:danger] = "#{@task.name}の更新は失敗しました。" + @task.errors.full_messages[0]
    end
    redirect_to step_tasks_url(@step)
  end

  def edit_check_status_1
  end

  def update_check_status_1
    if params[:status_1] == "continue"
      task1 = Task.new(step_id: @step.id ,name: "new_task", status: 0, scheduled_complete_date: Date.current.strftime("%Y-%m-%d"))
      if task1.save && update_completed_tasks_rate(@step)
        @step.update_attribute(:status, "in_progress")
        redirect_to step_tasks_url(@step)
      else
        flash[:danger] = "新しいタスクの追加に失敗しました"
        redirect_to step_tasks_url(@step)
      end
    else
      lead_id = @step.lead_id
      @step.destroy
      redirect_to lead_steps_url(lead_id)
    end
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
 
    def day_is_older_than_now(day)
      day.blank? ? false : Date.parse(day) < Date.current
    end

    def check_status
      if @step.tasks.where(status: "not_yet").count == 0 && @step.tasks.where(status: "completed").count == 0
        redirect_to tasks_edit_check_status_1_step_url(@step)
        #redirect_to tasks_edit_check_status_1_step_path(@step, format: "js")
      else
        redirect_to step_tasks_url(@step)
      end 
    end

end
