module UsersHelper
  # ユーザー名を表示する
  def user_name(id)
    @users.find(id).name
  end

  # 管理者は削除対象にできない設定+削除対象のユーザーと削除実行ユーザーが同じ企業IDか判定
  def delete_judgment(user)
    user.admin? || user.company_id != current_user.company_id ? false : true
  end

  # 引数のユーザーがcurrent_userと同じか判定
  def correct_user?(user)
    user == current_user ? true : false
  end
end
