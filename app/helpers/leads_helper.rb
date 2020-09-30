module LeadsHelper
  
  # 最後に更新した「進捗中」の進捗を取得
  def working_step_in(lead)
    if lead.present?
      working_steps = lead.steps.where(status: "in_progress")
      if working_steps.present?
        working_steps.order(:updated_at).last
      else
        latest_step_in(lead)
      end
    end
  end
  
  # 最終更新日を取得
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
  
  # 最後に終了した進捗を取得
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
