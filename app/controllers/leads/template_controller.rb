class Leads::TemplateController < Leads::ApplicationController
  # オブジェクトの準備
  before_action :set_lead_and_user, except: %i(index new create)
  before_action :set_users
  before_action ->{
    set_leads(Lead.where(template: true))
  }, only: %i(index)
  
  def index
  end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lead_and_user
      @lead = Lead.find(params[:id])
      @user = User.find(@lead.user_id)
    end
end
