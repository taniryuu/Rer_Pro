class Leads::TemplateController < Leads::ApplicationController
  # オブジェクトの準備
  before_action :set_lead_and_user, except: %i(index)
  before_action :set_users, only: %i(index)
  before_action ->{
    set_leads(Lead.where(template: true))
  }, only: %i(index)
  
  def index
  end
  
  # templateから作成
  def copy
    pre_criteria_date = Date.parse(@lead.created_date)
    new_criteria_date = Date.current
    date_difference = (new_criteria_date - pre_criteria_date).to_i
    new_lead = Lead.create!(
      user_id: current_user.id,
      created_date: new_criteria_date.to_s,
      customer_name: "#{@lead.customer_name}(#{@lead.template_name}のコピー)",
      room_name: "#{@lead.room_name}(#{@lead.template_name}のコピー)",
      room_num: "#{@lead.room_num}(#{@lead.template_name}のコピー)",
      scheduled_resident_date: (Date.parse(@lead.scheduled_resident_date) + date_difference).to_s,
      scheduled_payment_date: (Date.parse(@lead.scheduled_payment_date) + date_difference).to_s,
    )
    @lead.steps.all.each do |step|
      new_step = Step.create!(
        lead_id: new_lead.id,
        name: step.name,
        memo: step.memo,
        status: "in_progress",
        order: step.order,
        scheduled_complete_date: (Date.parse(step.scheduled_complete_date) + date_difference).to_s,
      )
      step.tasks.all.each do |task|
        Task.create!(
          step_id: new_step.id,
          name: task.name,
          memo: task.memo,
          status: task.status,
          scheduled_complete_date: (Date.parse(task.scheduled_complete_date) + date_difference).to_s,
        )
      end
    end
    flash[:success] = "テンプレートをコピーしました。名前を変更してください。"
    redirect_to edit_lead_url(new_lead)
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lead_and_user
      @lead = Lead.find(params[:id])
      @user = User.find(@lead.user_id)
    end
end
