class Step < ApplicationRecord
  belongs_to :lead
  has_many :tasks, dependent: :destroy
  default_scope -> { order(order: :asc) }
  
  validates :name, presence: true, length: { in: 2..50 }
  validates :memo, length: { in: 0..400 }
  validates :order, presence: true, uniqueness: { scope: :lead_id }, 
                    numericality: {only_integer: true, greater_than_or_equal_to: 1}
  validate :order_is_serial_number
  validates :status, presence: true
  validate :match_status_with_lead
  validates :scheduled_complete_date, presence: true, length: { in: 0..32 }, if: -> { status == "in_progress" }
  validates :completed_date, presence: true, length: { in: 0..32 }, if: -> { status == "completed" }
  validate :completed_date_prohibit_future
  validates :completed_tasks_rate, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100}
  enum status:[:not_yet, :inactive, :in_progress, :completed, :template] # 進捗ステータス
  
  # :orderカラムが連番であることを保証するには、最大値がレコードの数と一致する必要があるが、更新の都合上1つ余裕を持たせている。
  def order_is_serial_number
    steps_of_same_lead = Step.where(lead_id: self.lead_id)
    if steps_of_same_lead.present?
      unless steps_of_same_lead.pluck(:order).max <= steps_of_same_lead.count + 1
        errors.add(:order, "が「1から始まる連番」になっていません。")
      end
    end
  end
  
  # 進捗の:statusは、案件のstatusに対応するstatusが必要
  def match_status_with_lead
    lead = Lead.find(self.lead_id)
    if lead.status == "in_progress" && lead.steps.find_by(status: "in_progress").blank?
      errors.add(:status, ":進捗中の案件には、進捗中の進捗が少なくとも一つ以上必要です。") unless self.status == "in_progress"
    elsif lead.status == "completed" && lead.steps.find_by(status: "completed").blank?
      errors.add(:status, ":完了済の案件には、完了済の進捗が少なくとも一つ以上必要です。") unless self.status == "completed"
    elsif lead.status == "inactive" && lead.steps.find_by(status: "inactive").blank?
      errors.add(:status, ":凍結中の案件には、凍結中の進捗が必要です。") unless self.status == "inactive"
    end
  end
  
end
