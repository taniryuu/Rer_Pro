class Step < ApplicationRecord
  belongs_to :lead
  validates :name, presence: true, length: { in: 2..50 }
  validates :memo, length: { in: 0..400 }
  validates :order, presence: true, uniqueness: { scope: :lead_id }, 
                    numericality: {only_integer: true, greater_than_or_equal_to: 1}
  # validate :order_is_serial_number # コントローラー側の処理と合わせて設定する必要があるため、現在コメントアウト中。
  validates :status, presence: true
  validates :scheduled_complete_date, presence: true, length: { in: 0..32 }
  validates :completed_date, length: { in: 0..32 }
  validates :completed_tasks_rate, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100}
  enum status:[:not_yet, :inactive, :in_progress, :completed, :template] # 進捗ステータス
  
  # :orderカラムが連番であることを保証するには、最大値がレコードの数と一致する必要がある。
  def order_is_serial_number
    steps_of_same_lead = Step.where(lead_id: self.lead_id)
    unless steps_of_same_lead.count == steps_of_same_lead.pluck(:order).max
      errors.add(:order, "が「1から始まる連番」になっていません。")
    end
  end
  
end
