Company.create!(
  name: "システム管理",
  admin: true,
  status: 0
)
3.times do |i|
  User.create!(
    name: "SampleUser#{i}",
    email: "sample#{i}@email.com",
    login_id: "000#{i}",
    company_id: 1,
    admin: true,
    superior: true,
    password: "password",
  )
end
puts "システム管理者作成完了"
# ペルソナ用
# Company.create!(
#   name: "",
#   admin: false,
#   status: 0
# )
