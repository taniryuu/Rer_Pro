require 'rails_helper'

RSpec.describe Step, type: :model do
  company = FactoryBot.build(:company)
  company.save! if Company.find_by(name: company.name).blank?
  
  user = FactoryBot.build(:user)
  user.save! if User.find_by(name: user.name).blank?
  
  lead = FactoryBot.build(:lead)
  lead.save! if Lead.find_by(customer_name: lead.customer_name).blank?
  
  it "はlead_id, name, status, order, scheduled_complete_date, completed_tasks_rateカラムがあれば有効。" do
    expect(FactoryBot.build(:step)).to be_valid
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
                    # [:completed_date, 0, 32]
                  ]
  length_columns. each do |length_column|
    describe "の#{length_column[0]}は文字数制限あり" do
      it { should validate_length_of(length_column[0]).is_at_least(length_column[1]) }
      it { should validate_length_of(length_column[0]).is_at_most(length_column[2]) }
    end
  end
  
  # stepモデルを１つしか作っていないのにテストできているのか怪しいので、また時間のあるときに見直す。
  describe Step do
    context 'の:orderカラムは同じ案件内でuniqueness' do
      subject { FactoryBot.build(:step) }

      it do
        should validate_uniqueness_of(:order).
        scoped_to(:lead_id)
      end
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
