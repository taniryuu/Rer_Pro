class NotificationsController < Users::ApplicationController
  before_action :set_users

  # superior_idに指定されたユーザー視点の通知
  def notice
    @create_notices_list = [] # 新規作成時の通知をユーザー毎に取得して配列に格納
    @limit_change_notices_list = [] # 完了予定日変更時の通知をユーザー毎に取得して配列に格納
    @others_limit_notices_list = [] # superior_idに指定されたユーザーに届く通知をユーザー毎に取得して配列に格納
    @create_notices_user_num = [] # 新規作成時の案件のuser_idを取得
    @limit_change_notices_user_num = [] # 完了予定日変更時の案件のuser_idを取得
    @others_limit_notices_user_num = [] # superior_idに指定されたユーザーに届く通知を取得
    @create_notices_total_count = 0 # 新規作成時の通知件数を格納
    @limit_change_notices_total_count = 0 # 完了予定日変更時の通知件数を格納
    @others_limit_notices_total_count = 0 # superior_idに指定されたユーザーに届く通知件数を格納
    # 企業内の全ユーザーから通知送信先がcurrent_user.id,statusがactiveのユーザーに絞る
    users = @users.where(status: "active")
                  .where(superior_id: current_user.id)
    users.each do |user|
      leads = user.leads.in_progress
      if leads.present?
        # 案件create時の通知一覧
        create_notices = leads.where(notice_created: true)
        if create_notices.present?
          @create_notices_total_count += create_notices.count
          @create_notices_list.push(create_notices)
          @create_notices_user_num.push(user.id)
        end
        # 案件完了予定日を変更時の通知一覧
        limit_change_notices = leads.where(notice_change_limit: true)
        if limit_change_notices.present?
          @limit_change_notices_total_count += limit_change_notices.count
          @limit_change_notices_list.push(limit_change_notices)
          @limit_change_notices_user_num.push(user.id)
        end
        # 案件完了予定日の期限と現在の日付が同じ且つ過ぎている時
        others_limit_notices = leads.where.not(scheduled_contract_date: "").where("scheduled_contract_date <= ?", user.limit_date)
        if others_limit_notices.present?
          @others_limit_notices_total_count += others_limit_notices.count
          @others_limit_notices_list.push(others_limit_notices)
          @others_limit_notices_user_num.push(user.id)
        end
      end
    end
  end
end
