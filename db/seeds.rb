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
puts "Userテスト用サンプルレコード作成完了"

# Leadレコード作成
user_id = User.find_by(name: "サンプル太郎(0)").id
3.times do |i|
  Lead.create!(
    user_id: user_id,
    created_date: (Date.current - i).to_s,
  #  completed_date:	"",
    customer_name: "お客様#{i+1}",
    room_name: "物件#{i+1}",
    room_num:	"部屋#{i+1}",
  #  template: "",
  #  template_name: "",
  #  memo: "",
  #  status: "進捗中"
  #  notice_created: 新規申込時通知
  #  notice_change_limit: 期限変更時通知
    scheduled_resident_date: (Date.current + 21 - i).to_s,
    scheduled_payment_date: (Date.current + 14 - i).to_s,
  #  scheduled_contract_date: 契約予定日
  #  steps_rate: 進捗率
  )
end
puts "「SampleUser0」の案件作成完了"

# Stepレコード作成
7.times do |i|
  Step.create!(
    lead_id: 1,
    name: "進捗#{i+1}",
    memo: "進捗#{i+1}のメモ",
    status: 0,
    order: i+1,
    scheduled_complete_date: "#{Date.current + 3}",
    # completed_date: "",
    # completed_tasks_rate: 0
  )
end
puts "「SampleUser0」の案件「お客様1」の進捗作成完了"
