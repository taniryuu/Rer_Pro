require 'rails_helper'

RSpec.describe Lead, type: :model do
#  pending "add some examples to (or delete) #{__FILE__}"
  if Company.find_by(name: "サンプル企業").blank?
    Company.create!(
      name: "サンプル企業",
      admin: false,
      status: 0
    )
  end
  if User.find_by(name: "サンプル上長").blank?
    User.create!(
      name: "サンプル上長",
      company_id: 1,
      password: "password",
      login_id: "00001",
      superior: true,
      admin: false,
      superior_id: 1,
      lead_count: 0,
      lead_count_delay: 0,
      notified_num: 3,
      email: "sample@email.com",
      status: 0
    )
  end
  # 姓、名、メール、パスワードがあれば有効な状態であること
  it "はis valid with a created_date, customer_name, room_name, room_num, scheduled_resident_date, and scheduled_payment_date" do
    lead = Lead.create!(
      user_id: 1,
      created_date: Date.current.to_s,
    #  completed_date:	"",
      customer_name: "お客様A",
      room_name: "物件A",
      room_num:	"部屋A",
    #  template: "",
    #  template_name: "",
    #  memo: "",
    #  status: "進捗中"
    #  notice_created: 新規申込時通知
    #  notice_change_limit: 期限変更時通知
      scheduled_resident_date: (Date.current + 21).to_s,
      scheduled_payment_date: (Date.current + 14).to_s,
    #  scheduled_contract_date: 契約予定日
    #  steps_rate: 進捗率
    )
    expect(lead).to be_valid
  end

  # 名がなければ無効な状態であること
  it "is invalid without a event_name"
  # 姓がなければ無効な状態であること
  it "is invalid without a event_status"
  # メールアドレスがなければ無効な状態であること
  it "is invalid without an chouseisan_check"
  # 重複したメールアドレスなら無効な状態であること
  it "is invalid with a duplicate chouseisan_url"
  # ユーザーのフルネームを文字列として返すこと
  it "returns a event_name as a string"
end
