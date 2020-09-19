class Steps::StepStatusesController < StepsController
  
  def edit
  end
  
  def complete
    if params[:completed_id].present?
      completed_step = Step.find(params[:completed_id])
      complete_step(@lead, completed_step)
      if @lead.steps_rate < 100
        flash[:success] = "#{completed_step.name}を完了しました。引き続き、#{@step.name}に取り組んでください。"
        redirect_to @step
      else
        complete_lead(@lead)
        flash[:success] = "全ての進捗が完了し、本案件は終了済となりました。おつかれさまでした。"
        redirect_to @lead
      end
    end
  end
  
  def start
    if @step.update_attributes(status: "in_progress", scheduled_complete_date: params[:step][:scheduled_complete_date])
      if params[:completed_id].present?
        completed_step = Step.find(params[:completed_id])
        complete_step(@lead, completed_step)
        flash[:success] = "#{completed_step.name}を完了し、#{@step.name}を開始しました。"
      else
        update_completed_tasks_rate(@step)
        flash[:success] = "#{@step.name}を開始しました。"
      end
    else
      flash[:danger] = "完了予定日が正しく入力されていません。空欄は不可です。"
    end
    redirect_to @step
  end
  
  def cancel
  end
  
end
