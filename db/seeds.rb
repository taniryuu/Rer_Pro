# ペルソナ用
# Company.create!(
#   name: "",
#   admin: false,
#   status: 0
# )

# 管理者Companyレコード作成
Company.create!(
  name: "システム管理",
  admin: true,
  status: 0
)
puts "「システム管理」会社作成完了"

# 管理者Userレコード作成
3.times do |i|
  User.create!(
    name: "SampleUser#{i}",
    email: "sample#{i}@email.com",
    login_id: "000#{i}",
    company_id: 1,
    admin: true,
    superior: true,
    superior_id: 1,
    password: "password",
  )
end
puts "「システム管理」会社のユーザー作成完了"

#テスト用サンプルレコード
3.times do |i|
  Company.create!(
    name: "サンプル企業(#{i})",
    admin: false,
    status: 0
  )
end
puts "企業サンプル作成完了"

User.create!(
  name: "サンプル上長",
  company_id: 2,
  password: "password",
  login_id: "000020",
  superior: true,
  admin: true,
  superior_id: 4,
  lead_count: 0,
  lead_count_delay: 0,
  notified_num: 3,
  email: "joutyou@email.com",
  status: 0
)

10.times do |i|
  User.create!(
    name: "サンプル太郎(#{i})",
    company_id: 2,
    password: "password",
    login_id: "0000#{i}",
    superior: false,
    admin: false,
    superior_id: 4,
    lead_count: 0,
    lead_count_delay: 0,
    notified_num: 3,
    email: "sample-#{i}@email.com",
    status: 0
  )
end
puts "サンプル太郎(Userテスト用サンプルレコード)作成完了"

# Leadレコード作成
3.times do |i|
  Lead.create!(
    user_id: 1,
  #  created_date: "",
  #  completed_date:	"",
    customer_name: "お客様#{i}",
    room_name: "物件#{i}",
    room_num:	"部屋#{i}",
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
end
puts "「SampleUser0」の案件作成完了"
