require 'rails_helper'

RSpec.describe Lead, type: :model do
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
    #  template: false,
    #  template_name: "",
    #  memo: "",
    #  status: "進捗中"
    #  notice_created: true
    #  notice_change_limit: false
      scheduled_resident_date: (Date.current + 21).to_s,
      scheduled_payment_date: (Date.current + 14).to_s,
    #  scheduled_contract_date: ""
    #  steps_rate: 0
    )
    expect(lead).to be_valid
  end
  
  presense_columns = [:created_date, :customer_name, :room_name, :room_num, :scheduled_resident_date, :scheduled_payment_date]
  presense_columns. each do |presense_column|
    describe "の#{presense_column}がnilだと無効。" do
      it { should validate_presence_of(presense_column) }
    end
  end

  length_columns = [[:customer_name, 2, 50], 
                    [:room_name, 2, 50],
                    [:room_num, 1, 20],
                    [:memo, 0, 255],
                    [:template_name, 0, 50]
                  ]
  length_columns. each do |length_column|
    describe "の#{length_column[0]}は文字数制限あり" do
      it { should validate_length_of(length_column[0]).is_at_least(length_column[1]) }
      it { should validate_length_of(length_column[0]).is_at_most(length_column[2]) }
    end
  end
  
  # boolean型のカラムにtrueかfalseを許可し、nilは許可しない。
  # 参考サイト：https://note.com/ishibai/n/n2c27ff7288e3
  boolean_columns = [:notice_created, :notice_change_limit, :template]
  boolean_columns. each do |boolean_column|
    describe "の#{boolean_column}にtrueかfalseを許可。nilは無効。" do
      it { is_expected.to allow_value(true).for(boolean_column) }
      it { is_expected.to allow_value(false).for(boolean_column) }
      it { is_expected.not_to allow_value(nil).for(boolean_column) }
    end
  end

  it "はstatusがcompletedのときにcompleted_dateがnilだと無効。" do
    lead = Lead.new(status: "completed", completed_date: nil)
    lead.valid?
    expect(lead.errors[:completed_date]).to include("を入力してください")
  end
  
  it "はtemplateがtrueのときにtemplate_nameがnilだと無効。" do
    lead = Lead.new(template: true, template_name: nil)
    lead.valid?
    expect(lead.errors[:template_name]).to include("を入力してください")
  end
  
  it "はtemplateがtrueのときにtemplate_nameが1文字だと無効。" do
    lead = Lead.new(template: true, template_name: "a")
    lead.valid?
    expect(lead.errors[:template_name]).to include("は2文字以上で入力してください")
  end
  
end
