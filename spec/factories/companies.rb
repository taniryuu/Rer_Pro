FactoryBot.define do
  factory :company do
    name { "サンプルcompany1" }
    admin { false }
    status { 0 }

    trait :another do
      name { "サンプルcompany2" }
    end
  end
end
