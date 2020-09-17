class Leads::ApplicationController < ApplicationController
  before_action :authenticate_user!
  
  # 本日付で案件の完了処理を実行
  def complete_lead(lead)
    if lead.update_attributes(status: "completed", completed_date: "#{Date.current}", steps_rate: 100)
      flash[:success] = "完了しました"
      true
    else
      flash[:danger] = "案件の完了処理に失敗しました。システム管理者にご連絡ください。"
      false
    end
  end
  
  # 本日付で進捗の完了処理を実行
  def complete_step(lead, step)
    if step.update_attributes(status: "completed", completed_date: "#{Date.current}", completed_tasks_rate: 100)
      update_steps_rate(lead)
      flash[:success] = "完了しました"
      true
    else
      flash[:danger] = "#{step.name}の完了処理に失敗しました。システム管理者にご連絡ください。"
      false
    end
  end
  
  # leadの進捗率を更新
  def update_steps_rate(lead)
    not_yet_steps_num = lead.steps.where(status: ["not_yet", "in_progress"]).count
    completed_steps_num = lead.steps.where(status: "completed").count
    lead.update_attribute(:steps_rate, calculate_rate(completed_steps_num, not_yet_steps_num))
  end
  
  # stepのタスク達成率を更新
  def update_completed_tasks_rate(step)
    if step.id.present?
      not_yet_tasks_num = step.tasks.where(status: "not_yet").count
      completed_tasks_num = step.tasks.where(status: "completed").count
      new_rate = step.completed_date.present? ? 100 : calculate_rate(completed_tasks_num, not_yet_tasks_num)
      step.update_attribute(:completed_tasks_rate, new_rate)
    end
  end
  
  # 計算メソッド
  # 完了分と未了分から完了した割合を計算し、%を出力
  def calculate_rate(completed_num, not_yet_num)
    return not_yet_num > 0 ? 100 * completed_num / (completed_num + not_yet_num) : 0
  end
  
end
