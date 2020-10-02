class Leads::ApplicationController < Users::ApplicationController
  include LeadsHelper
  
  # 進捗の削除処理を実行
  def destroy_step(lead, step)
    # 本来ならモデルでvalidateしたい内容だが、削除後にバリデーションを通して失敗したらrollback、という実装に時間がかかりそうなので、とりあえずfatコントローラで対応した。
    steps_except_self = lead.steps.where.not(id: step.id).order(:order)
    if steps_except_self.blank?
      flash[:danger] = "#{step.name}を削除できません。案件には、進捗が少なくとも一つ以上必要です。"
    elsif lead.status == "in_progress" && steps_except_self.find_by(status: "in_progress").blank?
      flash[:danger] = "#{step.name}を削除できません。進捗中の案件には、進捗中の進捗が少なくとも一つ以上必要です。"
    elsif lead.status == "completed" && steps_except_self.find_by(status: "completed").blank?
      flash[:danger] = "#{step.name}を削除できません。終了済の案件には、完了済の進捗が少なくとも一つ以上必要です。"
    elsif lead.status == "inactive" && steps_except_self.find_by(status: "inactive").blank?
      flash[:danger] = "#{step.name}を削除できません。凍結中の案件には、中止した進捗が少なくとも一つ以上必要です。"
    else
      step.destroy
      check_status_completed_or_not(lead, nil)
      flash[:success] = "#{step.name}を削除しました。"
    end
    redirect_to Step.find_by(id: step.id).present? ? step : working_step_in(lead)
  end
  
  # 本日付で案件の完了処理を実行
  def complete_lead(lead)
    if lead.update_attributes(status: "completed", completed_date: "#{Date.current}")
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
      true
    else
      flash[:danger] = "#{step.name}の完了処理に失敗しました。システム管理者にご連絡ください。"
      false
    end
  end
  
  # 進捗の完了状態を確認し、他カラムとの整合性を担保
  def check_status_completed_or_not(lead, step)
    
    # stepがnilでなければ、stepの整合性を担保
    if step.present?
      update_completed_tasks_rate(step)
      if step.completed_date.present? && step.completed_tasks_rate < 100 # ここから未完了に揃える処理
        if step.status == "completed"
          if step.scheduled_complete_date.blank?
            step.update_attributes(completed_date: "", status: "in_progress", scheduled_complete_date: "#{Date.current}")
          else
            step.update_attributes(completed_date: "", status: "in_progress")
          end
        else
          step.update_attributes(completed_date: "")
        end
      elsif step.status != "completed" && step.completed_tasks_rate == 100 # ここから完了状態に揃える処理
        if step.completed_date.blank?
          step.update_attributes(status: "completed", completed_date: "#{Date.current}")
        else
          step.update_attributes(status: "completed")
        end
      end
    end
    
    # leadの整合性を担保
    update_steps_rate(lead)
    if lead.completed_date.present? && lead.steps_rate < 100 # ここから未完了に揃える処理
      if lead.status == "completed"
        lead.update_attributes(status: "in_progress", completed_date: "")
      else 
        lead.update_attributes(status: "in_progress")
      end
    elsif lead.status != "completed" && lead.steps_rate ==100 # ここから完了状態に揃える処理
      if lead.completed_date.blank?
        lead.update_attributes(status: "completed", completed_date: "#{Date.current}")
      else
        lead.update_attributes(status: "completed")
      end
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
      new_rate = (step.completed_date.present? && step.status == "completed" && step.tasks.blank?) ? 100 : calculate_rate(completed_tasks_num, not_yet_tasks_num)
      step.update_attribute(:completed_tasks_rate, new_rate)
    end
  end
  
  # 計算メソッド
  # 完了分と未了分から完了した割合を計算し、%を出力
  def calculate_rate(completed_num, not_yet_num)
    return completed_num == 0 ? 0 : 100 * completed_num / (completed_num + not_yet_num)
  end
 
  def cancel_step(lead, step)
    if step.update_attributes(status: "inactive", canceled_date: "#{Date.current}")
      check_status_completed_or_not(lead, step)
      flash[:success] = "#{step.name}を中止しました。以後、本進捗は通知対象になりません。"
    else
      flash[:danger] = step.errors.full_messages.first
    end
    redirect_to step
  end
  
 
end
