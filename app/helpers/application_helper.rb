module ApplicationHelper
  # 引数のusersで取ってきた複数のユーザーをusers_listにpushしてリストを作成
  def users_list(users)
    users_list = []
    if users.present?
      users.each do |user|
        users_list.push(["#{user.name}", user.id])
      end
    else
      users_list.push(["該当する社員がいません"])
    end
    return users_list
  end

  # set_usersをbefore_actionしていて引数のusersに@usersを充てる
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
  
  # 順番に存在確認し、存在する値を出力。ひとつ出力したらそれ以降は無視。全て存在しない場合のみnilを返す。引数は配列で渡すこと。（例）present_value([A, B])で、Aが存在すればAを返す、Aが存在しなければBを返す（Bが存在しなければnilを返す）
  def present_value(array)
    array.each do |obj|
      return obj if obj.present?
    end
  end
  
end
