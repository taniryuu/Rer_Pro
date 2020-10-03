class Lead < ApplicationRecord
  belongs_to :user
  has_many :steps, dependent: :destroy
  
  validates :created_date, presence: true
  validates :completed_date, presence: true, if: -> { status == "completed" }
  validate :completed_date_prohibit_future
  validates :customer_name, presence: true, length: { in: 2..50 }
  validates :room_name, presence: true, length: { in: 2..50 }
  validates :room_num, presence: true, length: { in: 1..20 }
  validates :memo, length: { in: 0..255 }
  validates :status, presence: true
  validates :scheduled_resident_date, presence: true
  validates :scheduled_payment_date, presence: true
  validates :notice_created, inclusion: { in: [true, false] }
  validates :notice_change_limit, inclusion: { in: [true, false] }
  validates :template, inclusion: { in: [true, false] }
  validates :template_name, length: { maximum: 50 }
  with_options if: proc { |s| s.template? } do |model|
    model.validates :template_name, presence: true, length: { minimum: 2 }
  end
  validate :match_steps_status, on: :check_steps_status
  enum status:[:in_progress, :completed, :inactive] # 案件ステータス
  
  # 案件検索機能。
  def Lead.search(search_column, search_word)
    return Lead.all unless search_word
    Lead.where(["#{search_column} LIKE ?", "%#{search_word}%"])
  end
  
  # 進捗の:statusは、案件のstatusに対応するstatusが必要。@lead.valid?(:check_steps_status)したときのみバリデーションを実行。
  def match_steps_status
    if self.status == "in_progress" && self.steps.in_progress.blank?
      errors.add(:status, ":進捗中の案件には、進捗中の進捗が少なくとも一つ以上必要です。")
    elsif self.status == "completed" && self.steps.completed.blank?
      errors.add(:status, ":完了済の案件には、完了済の進捗が少なくとも一つ以上必要です。")
    elsif self.status == "inactive" && self.steps.inactive.blank?
      errors.add(:status, ":凍結中の案件には、凍結中の進捗が必要です。")
    end
  end
  
end
