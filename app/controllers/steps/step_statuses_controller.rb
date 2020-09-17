class Steps::StepStatusesController < StepsController
  # オブジェクトの準備
#  before_action :set_step
  
  def edit
  end
  
  def start
#      debugger
    if @step.update_attributes(status: "in_progress", scheduled_complete_date: params[:step][:scheduled_complete_date])
      if params[:completed_id].present?
        completed_step = Step.find(params[:completed_id])
        complete_step(completed_step)
        flash[:success] = "#{completed_step.name}を完了し、#{@step.name}を開始しました。"
      else
        flash[:success] = "#{@step.name}を開始しました。"
      end
      redirect_to @step
    else
      flash[:danger] = "完了予定日が正しく入力されていません。空欄は不可です。"
      redirect_to lead_steps_path(@lead)
    end
  end
  
  def cancel
  end
end
