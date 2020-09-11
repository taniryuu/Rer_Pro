FactoryBot.define do
  factory :step do
    lead_id { 1 }
    name { "進捗1" }
    # memo: "進捗#{i+1}のメモ",
    status { 0 }
    order { 1 }
    scheduled_complete_date { "#{Date.current + 3}" }
    # completed_date: "",
    completed_tasks_rate { 0 }
  end
end
