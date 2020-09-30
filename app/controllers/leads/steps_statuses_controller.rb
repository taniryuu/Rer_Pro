class Leads::StepsStatusesController < Leads::StepsController
  
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
    ActiveRecord::Base.transaction do
      case @step.status
        when "not_yet"
          @success_message = "#{@step.name}を開始しました。" if @step.update_attributes(status: "in_progress", scheduled_complete_date: params[:step][:scheduled_complete_date])
        when "inactive"
          @success_message = "#{@step.name}を再開しました。" if @step.update_attributes(status: "in_progress", scheduled_complete_date: params[:step][:scheduled_complete_date], canceled_date: "")
        when "in_progress"
          @success_message = "#{@step.name}は既に進捗中です。"
        when "completed"
          @success_message = "#{@step.name}を再開しました。" if @step.update_attributes(status: "in_progress", scheduled_complete_date: params[:step][:scheduled_complete_date], completed_date: "")
      end
      update_completed_tasks_rate(@step)
      if params[:completed_id].present?
        completed_step = Step.find(params[:completed_id])
        complete_step(@lead, completed_step)
        @success_message = "#{completed_step.name}を完了し、#{@step.name}を開始しました。"
      else
        update_steps_rate(@lead)
      end
      check_status_completed_or_not(@lead, @step)
      raise ActiveRecord::Rollback if @lead.errors.present? || @step.errors.present?
    end
    
    if @step.errors.present?
      flash[:danger] = "完了予定日が正しく入力されていません。空欄は不可です。"
    else
      flash[:success] = @success_message
    end
    redirect_to @step
        
  end
  
  def cancel
#    if @step.update_attributes(status: "inactive", canceled_date: "#{Date.current}")
#      check_status_completed_or_not(@lead, @step)
#      flash[:success] = "#{@step.name}を中止しました。以後、本進捗は通知対象になりません。"
#    else
#      flash[:danger] = "#{@step.name}の中止処理に失敗しました。システム管理者にご連絡ください。"
#    end
#    redirect_to @step
    cancel_step(@lead, @step)
  end
  
end
