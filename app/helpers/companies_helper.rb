module CompaniesHelper
  # ユーザーIDを引数にユーザー情報を返す(Company#create ログイン時)
  def set_user(id)
    User.find(id)
  end
end
