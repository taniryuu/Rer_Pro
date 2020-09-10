module UsersHelper
  def same_company_id_judge(user)
    user.company_id == current_user.company_id ? true : false
  end
end
