class NotificationsController < Users::ApplicationController
  before_action :set_member

  # 上長視点の通知
  def notice
    @member =[]
    create_notices = []
    limit_change_notices = []
    # @usersを通知送信先がcurrent_user.id,statusがactiveのユーザーに絞る
    users = @users.where(superior_id: current_user.id)
                  .where(status: "active")
    users.each do |user|
      user.leads.each do |lead|
        # 案件create時の通知一覧
        if lead.notice_created == true
          create_notices.push(lead)
        end
        # 案件完了予定日を変更時の通知一覧
        if lead.notice_change_limit == true
          limit_change_notices.push(lead)
        end
      end
      # create_notices || limit_change_noticesが追加されたら
      # @memberにユーザー名と追加されたcreate_notices,limit_change_noticesを追加する
      @member.add(user.name, [create_notices, limit_change_notices])
    end
  end
end
