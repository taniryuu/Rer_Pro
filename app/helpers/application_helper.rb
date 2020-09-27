module ApplicationHelper
  # 引数のusersで取ってきた複数のユーザーをmember_listにpushしてリストを作成
  def member_list(users)
    member_list = []
    users.each do |user|
      member_list.push(["#{user.name}", user.id])
    end
    return member_list
  end

  # 自分以外&&上長を取得しリスト作成。自分が上長の場合users全員&&自分以外をリスト作成
  def superior_list(users, login_user)
    superior_list = []
    if login_user.superior?
      users.each do |user|
        superior_list.push(["#{user.name}", user.id]) unless user == login_user
      end
    else
      users.each do |user|
        superior_list.push(["#{user.name}", user.id]) if user != login_user && user.superior?
      end
    end
    return superior_list
  end

  # 企業名を取得
  def company_name(user)
    Company.find(user.company_id).name
  end
end
