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
5.times do |j|
  if user = User.find_by(name: "サンプル太郎(#{j})")
    user_id = user.id
    7.times do |i|
      Lead.create!(
        user_id: user_id,
        created_date: (Date.current - i).to_s,
      #  completed_date:	"",
        customer_name: "お客様#{j+1}#{i+1}",
        room_name: "物件#{i*j + 1}",
        room_num:	"#{100 + i + j}",
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
      Step.create!(
        lead_id: 1 + i + 7*j,
        name: "進捗#{1 + i + 7*j}-1",
        memo: "進捗#{1 + i + 7*j}-1のメモ",
        status: "in_progress",
        order: 1,
        scheduled_complete_date: "#{Date.current + 3}",
      )
    end
    puts "「サンプル太郎(#{j})」の案件作成完了"
  end
end

# Stepレコード作成
6.times do |i|
  Step.create!(
    lead_id: 1,
    name: "進捗#{i+2}",
    memo: "進捗#{i+2}のメモ",
    status: 0,
    order: i+2,
    scheduled_complete_date: "#{Date.current + 3 + i}",
  )
end
puts "「SampleUser0」の案件「お客様1」の進捗作成完了"

# status「未」のtaskレコード作成
3.times do |i|
  Task.create!(
    step_id: 1,
    name: "task#{i+1}",
    memo: "memo#{i+1}",
    status: 0,
    scheduled_complete_date: (I18n.l Date.current + 3, format: :standard),
  )
end

# status「完了」のtaskレコード作成
3.times do |i|
  Task.create!(
    step_id: 1,
    name: "task#{i+4}",
    memo: "memo#{i+4}",
    status: 1,
    scheduled_complete_date: (I18n.l Date.current + 4, format: :standard),
    completed_date: (I18n.l Date.current, format: :standard),
  )
end

# status「中止」のtaskレコード作成
3.times do |i|
  Task.create!(
    step_id: 1,
    name: "task#{i+7}",
    memo: "memo#{i+7}",
    status: 2,
    scheduled_complete_date: (I18n.l Date.current + 5, format: :standard),
    canceled_date: (I18n.l Date.current - 1, format: :standard),
  )
end
puts "「SampleUser0」の案件「お客様１」の「進捗１」のタスク作成完了"

