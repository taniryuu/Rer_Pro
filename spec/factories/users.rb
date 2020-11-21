FactoryBot.define do
  factory :admin_user do
    name { "サンプル管理者" }
    company_id { 1 }
    password { "password" }
    login_id { "00001" }
    superior { true }
    admin { true }
    superior_id { "" }
    lead_count { 0 }
    lead_count_delay { 0 }
    notified_num { 3 }
    email { "admin@example.com" }
    status { 0 }
  end

  factory :superior_user do
    name { "サンプル上長" }
    company_id { 1 }
    password { "password" }
    login_id { "00002" }
    superior { true }
    admin { false }
    superior_id { 1 }
    lead_count { 0 }
    lead_count_delay { 0 }
    notified_num { 3 }
    email { "superior@example.com" }
    status { 0 }
  end

  factory :user do
    name { "サンプルユーザー" }
    company_id { 1 }
    password { "password" }
    login_id { "00003" }
    superior { false }
    admin { false }
    superior_id { 1 }
    lead_count { 0 }
    lead_count_delay { 0 }
    notified_num { 3 }
    email { "sample@example.com" }
    status { 0 }
  end
end
