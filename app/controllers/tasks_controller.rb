class TasksController < Leads::ApplicationController
  before_action :set_task, only: %i(show edit update destroy)
  #before_action :set_lead_and_user_by_lead_id
  before_action :set_step, only: %i(index new create edit_add_delete_list update_add_delete_list)

  def index
    @tasks = @step.tasks.where(status: "not_yet").order(:scheduled_complete_date)
    @deleted_tasks_array = @step.tasks.where(status: "completed")
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
    today = Date.current
    year = today.year
    month = today.month
    day = today.day
    year_s = year.to_s
    if month < 10
      month_s = '0' + month.to_s
    else
      month_s = month.to_s
    end
    if day < 10
      day_s = '0' + day.to_s
    else
      day_s = day.to_s
    end
    today_s = year_s + '-' + month_s + '-' + day_s

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
    @deleted_tasks_array = @step.tasks.where(status: "completed")
    n1.times do |i1|
      if checkbox_array[i1] == "true"
        deleted_tasks = @step.tasks.where(status: "not_yet").order(:scheduled_complete_date).limit(1).offset(i1 - i2)
        i2 += 1
        deleted_tasks.each do |deleted_task|
          deleted_task.update_attribute(:status, "completed")
          deleted_task.update_attribute(:completed_date, today_s)
        end
      end
    end
    redirect_to lead_step_tasks_url(@lead, @step)
  end

  private
    def set_task
      @task = Task.find(params[:id])
      @step = Step.find(@task.step_id)
    end
 
    def set_step
      @step = Step.find(params[:step_id])
    end

    #Use callbacks to share common setup or constraints between actions.
    #def set_lead_and_user_by_lead_id
    #  @lead = Lead.find(params[:lead_id])
    #  @user = User.find(@lead.user_id)
    #end   

    def task_params
      params.require(:task).permit(:step_id, :name, :memo, :status, :scheduled_complete_date, :completed_date, :canceled_date)
    end 
end
