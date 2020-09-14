module UsersHelper
  # 管理者を削除不可、削除対象のユーザーと削除実行ユーザーが同じ企業IDか判定
  def delete_judge(user)
    user.admin? || user.company_id != current_user.company_id ? false : true
  end
end
