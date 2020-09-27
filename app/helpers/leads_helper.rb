module LeadsHelper
  # 最終更新日を返すメソッド
  def last_update_date(lead)
    if latest_step = latest_step_in(lead)
      case latest_step.status
      when "inactive"
        latest_step.canceled_date
      when "completed"
        latest_step.completed_date
      else
        lead.created_date
      end
    end
  end
  
  # 最後に終了した進捗を返すメソッド
  def latest_step_in(lead)
    if lead.present?
      inactive_step = lead.steps.find_by(status: "inactive")
      if inactive_step.present?
        inactive_step
      else
        completed_steps = lead.steps.where(status: "completed")
        completed_steps.present? ? completed_steps.order(:completed_date).last : lead.steps.where(status: "in_progress").order(:created_at).last
      end
    end
  end
  
end
