class Leads::StepsStatusesController < Leads::StepsController
  before_action :set_steps, only: %i(cancel start)
  before_action :set_tasks, only: %i(start)
  
  def complete
    if params[:completed_id].present?
      completed_step = Step.find(params[:completed_id])
      ActiveRecord::Base.transaction do
        complete_step(@lead, completed_step, completed_step.latest_date)
        if @lead.steps_rate < 100
          flash[:success] = "#{flash[:success]}引き続き、#{@step.name}に取り組んでください。"
        else
          complete_lead(@lead, completed_step.latest_date)
        end
        raise ActiveRecord::Rollback if @lead.invalid?(:check_steps_status)
      end
      if @lead.errors.blank?
        check_status_and_redirect_to(completed_step, @step)
      else
        flash[:danger] = "#{flash[:danger]}#{@lead.errors.full_messages.first}"
        redirect_to completed_step
      end
    else
      redirect_to @step
    end
  end
  
  def start
    errors = []
    ActiveRecord::Base.transaction do
      # 新規タスク作成
      if (@step.status?("in_progress") || @step.status?("inactive") || @step.status?("not_yet")) && @step.tasks.not_yet.blank?
        @task = @step.tasks.create(task_params)
        errors << @task.errors.full_messages if @task.invalid?
      end
      raise ActiveRecord::Rollback if errors.present?
    end
    if errors.present?
      render 'leads/steps/show'
    else
      start_step(@lead, @step)
    end
  end
  
  def cancel
    cancel_step(@lead, @step)
  end
  
  private

    def task_params
      params.require(:task).permit(:step_id, :name, :memo, :status, :scheduled_complete_date, :completed_date, :canceled_date)
    end

    def set_tasks
      @tasks = @step.tasks.not_yet.order(:scheduled_complete_date)
      @completed_tasks = @step.tasks.completed.order(:completed_date)
      @canceled_tasks = @step.tasks.canceled.order(:canceled_date)
    end

end
