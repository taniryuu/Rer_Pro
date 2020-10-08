class Leads::ApplicationController < Users::ApplicationController
  include LeadsHelper
  
  # 進捗の開始処理を実行し詳細ページへ遷移
  def start_step(lead, step)
    @success_message = "" # transaction内で代入した値を使うため、インスタンス変数を用いている。""を代入してリセットしている。
    ActiveRecord::Base.transaction do
        scheduled_complete_date = params[:step].present? ? params[:step][:scheduled_complete_date] : (l Date.current)
        case step.status
        when "not_yet"
          @success_message = "#{step.name}を開始しました。" if step.update_attributes(status: "in_progress", scheduled_complete_date: scheduled_complete_date)
        when "inactive"
          @success_message = "#{step.name}を再開しました。" if step.update_attributes(status: "in_progress", scheduled_complete_date: scheduled_complete_date, canceled_date: "")
        when "in_progress"
          @success_message = "#{step.name}は既に進捗中です。"
        when "completed"
          @success_message = "#{step.name}を再開しました。" if step.update_attributes(status: "in_progress", scheduled_complete_date: scheduled_complete_date, completed_date: "")
        end
       
      if params[:completed_id].present?
        completed_step = Step.find(params[:completed_id])
        @success_message = "#{flash[:success]}#{step.name}を開始しました。" if complete_step(lead, completed_step, "#{Date.current}")
      end
      check_status_completed_or_not(lead, step)
      raise ActiveRecord::Rollback if lead.invalid?(:check_steps_status) || step.errors.present?
    end
    if lead.errors.blank? && step.errors.blank?
      flash[:success] = @success_message if @success_message.present?
    else
      flash.delete(:success)
      flash[:danger] = lead.errors.full_messages.first if lead.errors.present?
      flash[:danger] = step.errors.full_messages.first if step.errors.present?
    end
    redirect_to step
  end
  
  # 進捗の中止処理を実行し詳細ページへ遷移
  def cancel_step(lead, step)
    ActiveRecord::Base.transaction do
      step.update_attributes(status: "inactive", canceled_date: "#{Date.current}")
      check_status_completed_or_not(lead, step)
      raise ActiveRecord::Rollback if lead.invalid?(:check_steps_status) || step.errors.present?
    end
    if lead.errors.blank? && step.errors.blank?
      flash[:success] = "#{step.name}を中止しました。以後、本進捗は通知対象になりません。"
    else
      flash[:danger] = step.errors.full_messages.first
      flash[:danger] = lead.errors.full_messages.first
    end
    redirect_to step
  end
  
  # 進捗の中止状態を確認し、他カラムとの整合性を担保
  def check_status_inactive_or_not(step)
    if step.status?("inactive") && step.canceled_date.blank?
      step.update_attribute(:canceled_date, "#{Date.current}")
    elsif !step.status?("inactive") && step.canceled_date.present?
      step.update_attribute(:canceled_date, "")
    end
  end
  
  # 進捗の削除処理を実行し詳細ページへ遷移
  def destroy_step(lead, step)
    ActiveRecord::Base.transaction do
      step.destroy
      check_status_completed_or_not(lead, nil)
      raise ActiveRecord::Rollback if lead.invalid?(:check_steps_status)
    end
    if lead.errors.blank?
      flash[:success] = "#{step.name}を削除しました。"
      redirect_to working_step_in(lead)
    else
      flash[:danger] = "#{step.name}を削除できませんでした。#{lead.errors.full_messages.first}"
      redirect_to step
    end
  end
  
  # 本日付で案件の完了処理を実行
  def complete_lead(lead, completed_date)
    if lead.update_attributes(status: "completed", completed_date: completed_date)
      flash[:success] = "全ての進捗が完了し、本案件は終了済となりました。おつかれさまでした。"
      true
    else
      flash[:danger] = lead.errors.full_messages.first
      false
    end
  end
  
  # 本日付で進捗の完了処理を実行
  def complete_step(lead, step, completed_date)
    if step.update_attributes(status: "completed", completed_date: completed_date, completed_tasks_rate: 100)
      update_steps_rate(lead)
      flash[:success] = "#{step.name}を完了しました。"
      true
    else
      flash[:danger] = step.errors.full_messages.first
      false
    end
  end
  
  # 進捗の完了状態を確認し、他カラムとの整合性を担保
  def check_status_completed_or_not(lead, step)
    
    # stepがnilでなければ、stepの整合性を担保
    if step.present?
      update_completed_tasks_rate(step)
      if step.completed_date.present? && step.completed_tasks_rate < 100 # ここから未完了に揃える処理
        if step.status?("completed")
          if step.scheduled_complete_date.blank?
            step.update_attributes(completed_date: "", status: "in_progress", scheduled_complete_date: "#{Date.current}")
          else
            step.update_attributes(completed_date: "", status: "in_progress")
          end
        else
          step.update_attributes(completed_date: "")
        end
      elsif !step.status?("completed") && step.completed_tasks_rate == 100 # ここから完了状態に揃える処理
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
      if lead.status?("completed")
        lead.update_attributes(status: "in_progress", completed_date: "")
      else 
        lead.update_attributes(status: "in_progress")
      end
    elsif !lead.status?("completed") && lead.steps_rate == 100 # ここから完了状態に揃える処理
      if lead.completed_date.blank?
        lead.update_attributes(status: "completed", completed_date: "#{Date.current}")
      else
        lead.update_attributes(status: "completed")
      end
    end
    
  end
  
  # leadの進捗率を更新
  def update_steps_rate(lead)
    lead.update_attribute(:steps_rate, calculate_rate(lead.steps.completed.count, lead.steps.todo.count))
  end
  
  # stepのタスク達成率を更新
  def update_completed_tasks_rate(step)
    if step.id.present?
      new_rate = (step.completed_date.present? && step.status?("completed") && step.tasks.blank?) ? 100 : calculate_rate(step.tasks.completed.count, step.tasks.not_yet.count)
      step.update_attribute(:completed_tasks_rate, new_rate)
    end
  end
  
  # 計算メソッド
  # 完了分と未了分から完了した割合を計算し、%を出力
  def calculate_rate(completed_num, not_yet_num)
    return completed_num == 0 ? 0 : 100 * completed_num / (completed_num + not_yet_num)
  end
  
end
