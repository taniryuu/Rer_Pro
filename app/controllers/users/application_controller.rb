class Users::ApplicationController < ApplicationController
  before_action :authenticate_user!
  
  # userの案件数を更新
  def update_lead_count(user)
    user.update_attribute(:lead_count, user.leads.in_progress.count)
  end
  
end
