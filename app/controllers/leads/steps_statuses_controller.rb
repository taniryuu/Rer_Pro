class Leads::StepsStatusesController < Leads::StepsController
  before_action :set_steps, only: %i(cancel)
  
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
        if $step_num == 0
          $step_num += 1
          redirect_to check_status_and_get_url(completed_step, @step)
        else
          redirect_to @step
        end
      else
        flash[:danger] = "#{flash[:danger]}#{@lead.errors.full_messages.first}"
        redirect_to completed_step
      end
    else
      redirect_to @step
    end
  end
  
  def start
    start_step(@lead, @step)
  end
  
  def cancel
    cancel_step(@lead, @step)
  end
  
end
