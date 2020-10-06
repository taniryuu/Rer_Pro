module ApplicationHelper
  # 引数のusersで取ってきた複数のユーザーをmember_listにpushしてリストを作成
  def member_list(users)
    member_list = []
    if users.present?
      users.each do |user|
        member_list.push(["#{user.name}", user.id])
      end
    else
      member_list.push(["該当する社員がいません"])
    end
    return member_list
  end

  # set_memberをbefore_actionしていて引数のusersに@usersを充てる
  # 引数が上長==trueなら自分以外&&アクティブユーザーを取得、違う場合自分以外&&アクティブな上長の全員を取得する
  def superior_users(users, login_user)
    if login_user.superior?
      users.where.not(id: login_user.id).where(status: "active")
    else
      users.where.not(id: login_user.id).where(superior: true).where(status: "active")
    end
  end

  # 企業名を取得
  def company_name(user)
    Company.find(user.company_id).name
  end
end
