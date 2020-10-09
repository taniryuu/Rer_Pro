class NotificationsController < Users::ApplicationController
  before_action :set_member

  # 上長視点の通知
  def notice
    @create_notices_list = [] # 新規作成時の通知をユーザー毎に取得して配列に格納
    @limit_change_notices_list = [] # 完了予定日変更時の通知をユーザー毎に取得して配列に格納
    @create_notices_user_num = [] # 新規作成時の案件のuser_idを取得
    @limit_change_notices_user_num = [] # 完了予定日変更時の案件のuser_idを取得
    @create_notices_total_count = 0 # 新規作成時の通知件数を格納
    @limit_change_notices_total_count = 0 # 完了予定日変更時の通知件数を格納
    
    # @usersを通知送信先がcurrent_user.id,statusがactiveのユーザーに絞る
    users = @users.where(status: "active")
                  .where(superior_id: current_user.id)
    users.each do |user|
      leads = user.leads.where(status: "in_progress")
      if leads.present?
        # 案件create時の通知一覧
        if leads.where(notice_created: true).present?
          @create_notices_total_count += leads.count
          @create_notices_list.push(leads.where(notice_created: true)) 
          @create_notices_user_num.push(leads.select(:user_id).distinct)
        end
        # 案件完了予定日を変更時の通知一覧
        if leads.where(notice_change_limit: true).present?
          @limit_change_notices_total_count += leads.count
          @limit_change_notices_list.push(leads.where(notice_change_limit: true))
          @limit_change_notices_user_num.push(leads.select(:user_id).distinct)
        end
      end
    end
  end
end
