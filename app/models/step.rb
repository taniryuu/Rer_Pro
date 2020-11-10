class Step < ApplicationRecord
  belongs_to :lead
  has_many :tasks, dependent: :destroy, inverse_of: :step
  scope :ord, -> { order(:order) }
  
  validates :name, presence: true, length: { in: 2..50 }
  validates :memo, length: { in: 0..400 }
  validates :order, presence: true, uniqueness: { scope: :lead_id }, 
                    numericality: {only_integer: true, greater_than_or_equal_to: 1}
  validate :order_is_serial_number, on: :check_order
  validates :status, presence: true
  validates :scheduled_complete_date, presence: true, length: { in: 0..32 }, if: -> { status == "in_progress" }
  validates :completed_date, presence: true, length: { in: 0..32 }, if: -> { status == "completed" }
  validate :completed_date_prohibit_future
  validates :completed_tasks_rate, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100}
  #validate :match_tasks_status, on: :check_tasks_status
  validates :notice_change_limit, inclusion: { in: [true, false] }
  enum status:[:not_yet, :inactive, :in_progress, :completed, :template] # 進捗ステータス
  
  # :orderカラムが連番であることを保証するには、最大値がレコードの数と一致する必要がある。@step.valid?(:check_order)したときのみバリデーションを実行。
  def order_is_serial_number
    steps_of_same_lead = Step.where(lead_id: self.lead_id)
    if steps_of_same_lead.present?
      unless steps_of_same_lead.pluck(:order).max <= steps_of_same_lead.count
        errors.add(:order, "が「1から始まる連番」になっていません。")
      end
    end
  end
  
  # タスクの:statusは、進捗のstatusに対応するstatusが必要。@step.valid?(:check_tasks_status)したときのみバリデーションを実行。
  #def match_tasks_status
  #  if self.status?("in_progress") && self.tasks.not_yet.blank?
  #    errors.add(:status, ":進捗中の進捗には、未のタスクが少なくとも一つ以上必要です。")
  #  elsif self.status?("completed") && self.tasks.completed.blank?
  #    errors.add(:status, ":完了済みの進捗には、完了済のタスクが少なくとも一つ以上必要です。")
  #  end
  #end
 
  # メソッド
  
  # statusに応じた終了日を取得（ない場合は""）
  def finish_date
    case self.status
    when "not_yet"
      if self.scheduled_complete_date.present?
        self.scheduled_complete_date
      else
        self.back_step.present? ? self.back_step.finish_date : ""#Float::INFINITY
      end
    when "in_progress"
      self.scheduled_complete_date
    when "inactive"
      self.canceled_date
    when "completed"
      self.completed_date
    when "template"
      ""#Float::INFINITY
    end
  end
  
  # 次の順番の進捗を取得（ない場合はnil）
  def next_step
    Step.find_by(lead_id: self.lead_id, order: self.order + 1)
  end
  
  # 前の順番の進捗を取得（ない場合はnil）
  def back_step
    Step.find_by(lead_id: self.lead_id, order: self.order - 1)
  end
  
  # stautsが「完了」のタスクの中でもっとも遅い「完了日」を取得（なければ本日の日付）
  def latest_date
    self.tasks.completed.present? ? self.tasks.completed.maximum(:completed_date) : "#{Date.current}"
  end
    
end
