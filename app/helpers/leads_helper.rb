module LeadsHelper
  
  # 最後に更新した「進捗中」の進捗を取得（ない場合は、最後に終了した進捗を取得）
  def working_step_in(lead)
    if lead.present?
      working_steps = lead.steps.in_progress
      return working_steps.present? ? working_steps.order(:updated_at).last : latest_step_in(lead)
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
  
  # 最後に終了した進捗を取得（ない場合は、最後に更新した「進捗中」の進捗を取得）
  def latest_step_in(lead)
    if lead.present?
      completed_steps = lead.steps.completed
      completed_step = completed_steps.order(:completed_date).last if completed_steps.present?
      inactive_steps = lead.steps.inactive
      inactive_step = inactive_steps.order(:canceled_date).last if inactive_steps.present?
      if completed_step.present? && inactive_step.present?
        if completed_step.completed_date >= inactive_step.canceled_date
          return completed_step
        else
          return inactive_step
        end
      elsif completed_step.present?
        return completed_step
      elsif inactive_step.present?
        return inactive_step
      else
        return lead.steps.in_progress.order(:created_at).last
      end
    end
  end
  
  # 進捗一覧のシンボルサイズ
  def step_button_size(step_now, step)
    step_now.id == step.id ? "btn-lg" : "btn-sm"
  end
  
  # 進捗一覧のシンボルの色
  def step_button_color(step)
    case step.status
    when "not_yet"
      "btn-default"
    when "inactive"
      "btn-danger"
    when "in_progress"
      "btn-info"
    when "completed"
      "btn-secondary"
    end
  end
  
end
