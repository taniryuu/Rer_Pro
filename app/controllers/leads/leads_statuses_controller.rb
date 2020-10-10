class Leads::LeadsStatusesController < Leads::LeadsController
  before_action :correct_user, only: %i(start cancel)
  
  def edit
  end

  def start
    if start_lead(@lead)
      redirect_to Step.find(params[:step_id])
    else
      redirect_to working_step_in(lead)
    end
  end

  def cancel
    cancel_lead(@lead)
  end
end
