FactoryBot.define do
  factory :user do
    name { "サンプル上長" }
    company_id { 1 }
    password { "password" }
    login_id { "00001" }
    superior { true }
    admin { false }
    superior_id { 1 }
    lead_count { 0 }
    lead_count_delay { 0 }
    notified_num { 3 }
    email { "sample@email.com" }
    status { 0 }
  end
end
