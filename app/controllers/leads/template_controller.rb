class Leads::TemplateController < Leads::ApplicationController
  # オブジェクトの準備
  before_action :set_users, only: %i(index)
  before_action ->{
    set_leads(Lead.where(template: true))
  }, only: %i(index)
  
  def index
  end
  
end
