require 'rails_helper'

RSpec.describe Step, type: :model do
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
  if Lead.find_by(customer_name: "お客様A").blank?
    Lead.create!(
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
  end
  
  it "はlead_id, name, status, order, scheduled_complete_date, completed_tasks_rateカラムがあれば有効。" do
    step = Step.create!(
      lead_id: 1,
      name: "進捗1",
      # memo: "進捗#{i+1}のメモ",
      status: 0,
      order: 1,
      scheduled_complete_date: "#{Date.current + 3}",
      # completed_date: "",
      completed_tasks_rate: 0
    )
    expect(step).to be_valid
  end
  
  presense_columns = [:name, :status, :order, :scheduled_complete_date, :completed_tasks_rate]
  presense_columns. each do |presense_column|
    describe "の#{presense_column}がnilだと無効。" do
      it { should validate_presence_of(presense_column) }
    end
  end
  
  length_columns = [[:name, 2, 50], 
                    [:memo, 0, 400],
                    [:scheduled_complete_date, 0, 32],
                    [:completed_date, 0, 32]
                  ]
  length_columns. each do |length_column|
    describe "の#{length_column[0]}は文字数制限あり" do
      it { should validate_length_of(length_column[0]).is_at_least(length_column[1]) }
      it { should validate_length_of(length_column[0]).is_at_most(length_column[2]) }
    end
  end
  
  # gem 'factory_bot_rails'が必要。少し時間がかかりそうなので後回し。
  describe Step do
    context 'の:orderカラムは同じ案件内でuniqueness' do
      # subject { FactoryBot.build(:step) }
  
      # it do
      #   should validate_uniqueness_of(:order).
      #     scoped_to(:lead_id)
      # end
    end
  end
  
  numericality_columns = [[:order, 1, nil], 
                          [:completed_tasks_rate, 0, 100]
                        ]
  numericality_columns. each do |numericality_column|
    describe "の#{numericality_column[0]}は整数のみで範囲制限あり" do
      it { should validate_numericality_of(numericality_column[0]).only_integer }
      it { should validate_numericality_of(numericality_column[0]).is_greater_than_or_equal_to(numericality_column[1]) } if numericality_column[1].present?
      it { should validate_numericality_of(numericality_column[0]).is_less_than_or_equal_to(numericality_column[2]) } if numericality_column[2].present?
    end
  end
  
end
