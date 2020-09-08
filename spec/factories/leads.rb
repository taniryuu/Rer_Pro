FactoryBot.define do
  factory :lead do
    user_id { 1 }
    created_date { Date.current.to_s }
  #  completed_date:	"",
    customer_name { "お客様A" }
    room_name { "物件A" }
    room_num {	"部屋A" }
  #  template: false,
  #  template_name: "",
  #  memo: "",
  #  status: "進捗中"
  #  notice_created: true
  #  notice_change_limit: false
    scheduled_resident_date { (Date.current + 21).to_s }
    scheduled_payment_date { (Date.current + 14).to_s }
  #  scheduled_contract_date: ""
  #  steps_rate: 0
  end
end
