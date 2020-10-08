class Leads::StepsStatusesController < Leads::StepsController
  
  def edit
  end
  
  def complete
    if params[:completed_id].present?
      ActiveRecord::Base.transaction do
        completed_step = Step.find(params[:completed_id])
        complete_step(@lead, completed_step, completed_step.latest_date)
        if @lead.steps_rate < 100
          flash[:success] = "#{flash[:success]}#{completed_step.name}を完了しました。引き続き、#{@step.name}に取り組んでください。"
        else
          complete_lead(@lead, completed_step.latest_date)
        end
        raise ActiveRecord::Rollback if @lead.invalid?(:check_steps_status)
      end
      redirect_to @step
    end
  end
  
  def start
    if [:step].present?
      new_task = params[:step][:new_task]
      start_step(@lead, @step, new_task)
    end
  end
  
  def cancel
    cancel_step(@lead, @step)
  end
  
end
