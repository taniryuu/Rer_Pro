class NotificationsController < Users::ApplicationController
  before_action :set_users
  before_action :notice
  
  # superior_idに指定されたユーザー視点の通知
  def notice
    # 新規作成時の通知
    @create_notices_list = [] # ユーザー毎に取得して配列に格納
    @create_notices_user_num = [] # 案件の担当ユーザーを取得
    @create_notices_total_count = 0 # 通知件数を格納
    # 完了予定日変更時
    @limit_change_notices_list = []
    @limit_change_notices_user_num = []
    @limit_change_notices_total_count = 0
    # 進捗の期限に遅延がある場合
    @step_limit_notices_list = []
    @step_limit_notices_user_num = []
    @step_limit_notices_total_count = 0
    # 企業内の全ユーザーから通知送信先がcurrent_user.id,statusがactiveのユーザーに絞る
    @active_users = @users.where(status: "active")
                          .where(superior_id: current_user.id)
    @active_users.each do |user|
      leads = user.leads.in_progress
      if leads.present?
        # 案件create時の通知一覧
        create_notices = leads.where(notice_created: true)
        if create_notices.present?
          @create_notices_list.push(create_notices)
          @create_notices_user_num.push(user.id)
          @create_notices_total_count += create_notices.count
        end
        # 案件完了予定日を変更時の通知一覧
        limit_change_notices = leads.where(notice_change_limit: true)
        if limit_change_notices.present?
          @limit_change_notices_list.push(limit_change_notices)
          @limit_change_notices_user_num.push(user.id)
          @limit_change_notices_total_count += limit_change_notices.count
        end
        # 進捗の予定日の期限と現在の日付が同じ且つ過ぎている時
        step_limit_notices = []
        leads.each do |lead|
          if lead.steps.todo.where("scheduled_complete_date <= ?", user.limit_date).present?
            step_limit_notices.push(lead)
          end
        end
        if step_limit_notices.present?
          @step_limit_notices_list.push(step_limit_notices)
          @step_limit_notices_user_num.push(user.id)
          @step_limit_notices_total_count += step_limit_notices.count
        end
      end
    end
  end

  def index
  end

  # 新規作成時通知をfalseに更新
  def update_create
    user = @active_users.find(params[:id])
    leads = user.leads.in_progress
    ActiveRecord::Base.transaction do
      leads.each { |lead| lead.update!(notice_created: false) }
      flash[:success] = "#{user.name}の案件を確認しました。"
      redirect_to notices_url(current_user)
    end

    rescue ActiveRecord::RecordInvalid
      flash[:danger] = "確認処理に失敗しました。操作をやり直してください。"
      redirect_to notices_url(current_user)
  end
end
