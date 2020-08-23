Company.create!(
  name: "システム管理",
  admin: true,
  status: 0
)
puts "システム管理者作成完了"
# ペルソナ用
# Company.create!(
#   name: "",
#   admin: false,
#   status: 0
# )


# #テスト用サンプルレコード
# User.create!(
#   name: "サンプル太郎",
# #  company_id: 0,
#   password: "password",
#   login_id: "XXXXXX",
#   superior: false,
#   admin: false,
#   superior_id: 0,
#   lead_count: 0,
#   lead_count_delay: 0,
#   notified_num: 3,
#   email: "sample_taro@email.com",
#   status: 0
# )
# puts "サンプル太郎(Userテスト用サンプルレコード)作成完了"

#テスト用サンプルレコード
Lead.create!(
#  user_id: 0,
#  created_date: "",
#  completed_date:	"",
  customer_name: "お客様A",
  room_name: "物件A",
  room_num:	"部屋A",
#  template: "",
#  template_name: "",
#  memo: "",
#  status: "進捗中"
#  notice_created: 新規申込時通知
#  notice_change_limit: 期限変更時通知
#  scheduled_resident_date: 入居予定日
#  scheduled_payment_date: 入金予定日
#  scheduled_contract_date: 契約予定日
#  steps_rate: 進捗率
)
puts "サンプル案件A(Leadテスト用サンプルレコード)作成完了"
