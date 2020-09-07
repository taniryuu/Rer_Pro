class TasksController < StepsController
  before_action :set_task, only: %i(show edit update destroy)
  #before_action :set_lead_and_user_by_lead_id
  before_action :set_step, only: %i(show index new create edit update)

  def index
    @tasks = Task.all
  end

  def show
  end

  def new
    @task = Task.new
  end

  def edit
  end

  def create
    @task = Task.new(task_params)
<<<<<<< HEAD
     respond_to do |format|
      if @task.save && update_completed_tasks_rate(@step)
=======
    respond_to do |format|
      if @task.save
>>>>>>> be17e783c9e51579cd0285d83788c55b05d64618
        format.html { redirect_to lead_step_tasks_path(params[:lead_id],params[:step_id]), notice: 'Task was successfully created.' }
        format.json { render :show, status: :created, location: lead_step_tasks_path(params[:lead_id],params[:step_id]) }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @task.update(task_params) && update_completed_tasks_rate(@step)
        format.html { redirect_to lead_step_tasks_path(params[:lead_id],params[:step_id]), notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: lead_step_tasks_path(params[:lead_id],params[:step_id]) }
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
      format.html { redirect_to lead_step_tasks_path(params[:lead_id],params[:step_id]), notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_task
      @task = Task.find(params[:id])
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
