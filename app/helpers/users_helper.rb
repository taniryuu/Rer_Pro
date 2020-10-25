module UsersHelper
  # ユーザー名を表示する
  def user_name(id)
    @users.find(id).name
  end

  # 建物名と部屋番号を繋げて表示する
  def room_name_num(lead)
    "#{lead.room_name}" + ":" + "#{lead.room_num}号室"
  end

  # 管理者は削除対象にできない設定+削除対象のユーザーと削除実行ユーザーが同じ企業IDか判定
  def delete_judgment(user)
    user.admin? || user.company_id != current_user.company_id ? false : true
  end
end
