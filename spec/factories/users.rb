FactoryBot.define do
  factory :user do
    # 一般ユーザー
    name { "サンプルユーザー" }
    password { "password" }
    login_id { "0001" }
    superior { false }
    admin { false }
    lead_count { 0 }
    lead_count_delay { 0 }
    notified_num { 3 }
    email { "sampleuser@example.com" }
    status { 0 }

    # 管理者ユーザー
    trait :admin do
      name { "管理者ユーザー" }
      login_id { "0000" }
      superior { true }
      admin { true }
      email { "adminuser@example.com" }
    end

    # 上長ユーザー
    trait :superior do
      name { "上長ユーザー" }
      login_id { "0002" }
      superior { true }
      email { "superioruser@example.com" }
    end

    # 休職中のユーザー
    trait :inactive do
      status { 1 }
    end
  end
end
