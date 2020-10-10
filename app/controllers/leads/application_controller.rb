class Leads::ApplicationController < Users::ApplicationController
  include LeadsHelper
  
  # 案件の開始処理を実行
  def start_lead(lead)
    if lead.update_attributes(status: "in_progress", completed_date: "", canceled_date: "") && lead.valid?(:check_steps_status)
      flash[:success] = "#{flash[:success]}本案件を再開しました。"
      true
    else
      flash[:danger] = "#{flash[:danger]}#{lead.errors.full_messages.first}"
      false
    end
  end
  
  # 進捗の開始処理を実行し詳細ページへ遷移
  def start_step(lead, step)
    @success_message = "" # transaction内で代入した値を使うため、インスタンス変数を用いている。""を代入してリセットしている。
    ActiveRecord::Base.transaction do
      # 開始処理
      scheduled_complete_date = params[:step].present? ? params[:step][:scheduled_complete_date] : "#{Date.current}"
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
      # 完了する進捗がある場合の処理
      if params[:completed_id].present?
        completed_step = Step.find(params[:completed_id])
        @success_message = "#{step.name}を開始しました。" if complete_step(lead, completed_step, completed_step.latest_date)
      end
      # 案件を再開する場合の処理
      start_lead(lead) unless lead.status?("in_progress")
      # 矛盾を解消
      check_status_completed_or_not(lead, step)
      # バリデーション確認
      raise ActiveRecord::Rollback if lead.invalid?(:check_steps_status) || step.errors.present?
    end
    if lead.errors.blank? && step.errors.blank?
      flash[:success] = "#{flash[:success]}#{@success_message}" if @success_message.present?
    else
      flash.delete(:success)
      flash[:danger] = "#{flash[:danger]}#{lead.errors.full_messages.first}" if lead.errors.present?
      flash[:danger] = "#{flash[:danger]}#{step.errors.full_messages.first}" if step.errors.present?
    end
    redirect_to step
  end
  
  # 案件を凍結し詳細ページへ遷移
  def cancel_lead(lead)
    ActiveRecord::Base.transaction do
      lead.update_attributes(status: "inactive", canceled_date: "#{Date.current}")
      check_status_completed_or_not(lead, nil)
      raise ActiveRecord::Rollback if lead.invalid?(:check_steps_status)
    end
    if lead.errors.blank?
      flash[:success] = "#{flash[:success]}本案件を凍結しました。以後、本案件は通知対象になりません。"
    else
      flash[:danger] = "#{flash[:danger]}#{lead.errors.full_messages.first}"
    end
    redirect_to latest_step_in(lead)
  end
  
  # 進捗の中止処理を実行し詳細ページへ遷移
  def cancel_step(lead, step)
    ActiveRecord::Base.transaction do
      step.update_attributes(status: "inactive", canceled_date: "#{Date.current}")
      check_status_completed_or_not(lead, step)
      raise ActiveRecord::Rollback if lead.invalid?(:check_steps_status) || step.errors.present?
    end
    if lead.errors.blank? && step.errors.blank?
      flash[:success] = "#{flash[:success]}#{step.name}を保留にしました。以後、本進捗は通知対象になりません。"
    else
      flash[:danger] = "#{flash[:danger]}#{step.errors.full_messages.first}"
      flash[:danger] = "#{flash[:danger]}#{lead.errors.full_messages.first}"
    end
    redirect_to step
  end
  
  # 案件または進捗の中止状態を確認し、他カラムとの整合性を担保
  def check_status_inactive_or_not(model)
    if model.status?("inactive") && model.canceled_date.blank?
      model.update_attribute(:canceled_date, "#{Date.current}")
    elsif !model.status?("inactive") && model.canceled_date.present?
      model.update_attribute(:canceled_date, "")
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
      flash[:success] = "#{flash[:success]}#{step.name}を削除しました。"
      redirect_to working_step_in(lead)
    else
      flash[:danger] = "#{flash[:danger]}#{step.name}を削除できませんでした。#{lead.errors.full_messages.first}"
      redirect_to step
    end
  end
  
  # 本日付で案件の完了処理を実行
  def complete_lead(lead, completed_date)
    if lead.update_attributes(status: "completed", completed_date: completed_date)
      flash[:success] = "#{flash[:success]}全ての進捗が完了し、本案件は終了済となりました。おつかれさまでした。"
      true
    else
      flash[:danger] = "#{flash[:danger]}#{lead.errors.full_messages.first}"
      false
    end
  end
  
  # 本日付で進捗の完了処理を実行
  def complete_step(lead, step, completed_date)
    if step.update_attributes(status: "completed", completed_date: completed_date, completed_tasks_rate: 100)
      update_steps_rate(lead)
      flash[:success] = "#{flash[:success]}#{step.name}を完了しました。"
      true
    else
      flash[:danger] = "#{flash[:danger]}#{step.errors.full_messages.first}"
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
        flash[:danger] = "#{flash[:danger]}未完了のタスクがあるため、#{step.name}を完了にできません。"
      elsif !step.status?("completed") && step.completed_tasks_rate == 100 # ここから完了状態に揃える処理
        if step.completed_date.blank?
          step.update_attributes(status: "completed", completed_date: "#{Date.current}")
        else
          step.update_attributes(status: "completed")
        end
        flash[:success] = "#{flash[:success]}未完了のタスクがないため、#{step.name}は完了となりました。"
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
      flash[:danger] = "#{flash[:danger]}未完了の進捗があるため、案件を進捗中にしました。"
    elsif lead.status?("in_progress") && lead.steps_rate == 100 # ここから完了状態に揃える処理
      if lead.completed_date.blank?
        lead.update_attributes(status: "completed", completed_date: "#{Date.current}")
      else
        lead.update_attributes(status: "completed")
      end
      flash[:success] = "#{flash[:success]}未完了の進捗がないため、案件は終了済となりました。"
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
  
  
  private
    # 進捗一覧を取得
    def set_steps
      @steps = @lead.steps.all.ord
      @steps_except_self = @steps.not_self(@step)
      @steps_from_now_on = @steps_except_self.todo
    end
    
end
