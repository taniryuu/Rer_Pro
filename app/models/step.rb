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
  validate :keep_status_in_progress
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
  
  # :statusは、進捗中にin_progressの少なくともどちらかがひとつ以上必要
  def keep_status_in_progress
    lead = Lead.find(self.lead_id)
    if lead.status == "in_progress" && lead.steps.where(status: "not_yet").present?
      errors.add(:order, "進捗中の案件には、進捗中の進捗が少なくとも一つ以上必要です。") if lead.steps.where(status: "in_progress").blank?
    end
  end
  
end
