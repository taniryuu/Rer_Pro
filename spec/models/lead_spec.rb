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
  
  it "はcreated_date, customer_name, room_name, room_num, scheduled_resident_date, scheduled_payment_dateカラムがあれば有効。" do
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
  
  it "はcreated_dateがnilだと無効。" do
    lead = Lead.new(created_date: nil)
    lead.valid?
    expect(lead.errors[:created_date]).to include("を入力してください")
  end

  it "はcustomer_nameがnilだと無効。" do
    lead = Lead.new(customer_name: nil)
    lead.valid?
    expect(lead.errors[:customer_name]).to include("を入力してください")
  end

  it "はroom_nameがnilだと無効。" do
    lead = Lead.new(room_name: nil)
    lead.valid?
    expect(lead.errors[:room_name]).to include("を入力してください")
  end

  it "はroom_numがnilだと無効。" do
    lead = Lead.new(room_num: nil)
    lead.valid?
    expect(lead.errors[:room_num]).to include("を入力してください")
  end

  it "はscheduled_resident_dateがnilだと無効。" do
    lead = Lead.new(scheduled_resident_date: nil)
    lead.valid?
    expect(lead.errors[:scheduled_resident_date]).to include("を入力してください")
  end

  it "はscheduled_payment_dateがnilだと無効。" do
    lead = Lead.new(scheduled_payment_date: nil)
    lead.valid?
    expect(lead.errors[:scheduled_payment_date]).to include("を入力してください")
  end
  
  # boolean型のカラムにtrueかfalseを許可し、nilは許可しないテストが未実装。
  # gem "shoulda-matchers" を導入して、allow_valueを使うのが簡単そう。
  # 参考サイト：https://note.com/ishibai/n/n2c27ff7288e3

  it "はtemplateがtrueのときにtemplate_nameがnilだと無効。" do
    lead = Lead.new(template: true, template_name: nil)
    lead.valid?
    expect(lead.errors[:template_name]).to include("を入力してください")
  end
  
end
