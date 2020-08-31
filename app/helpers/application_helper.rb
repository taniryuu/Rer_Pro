module ApplicationHelper
  # 自分以外且つ上長を取得しリスト作成。自分が上長の場合@users全員且つ自分以外をリスト作成
  def superior_list(users, login_user)
    superior_id = []
    if login_user.superior?
      users.each do |user|
        if user != login_user
          superior_id.push(["#{user.name}", user.id])
        end
      end
    else
      users.each do |user|
        superior_id.push(["#{user.name}", user.id]) if user != login_user || user.superior?
      end
    end
    return superior_id
  end
end
