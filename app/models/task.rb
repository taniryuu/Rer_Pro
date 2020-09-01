class Task < ApplicationRecord
  belongs_to :step
  validates :name, presence: true, length: { in: 0..60 }
  validates :memo, length: { in: 0..400 }
  validates :scheduled_complete_date, presence: true
  enum status: [:not_yet, :completed, :canceled] # 進捗ステータス
end
