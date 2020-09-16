class Task < ApplicationRecord
  belongs_to :step
  validates :name, presence: true, length: { in: 0..60 }
  validates :memo, length: { in: 0..400 }
  validates :scheduled_complete_date, presence: true
  enum status: [:not_yet, :completed, :canceled] # 進捗ステータス
  
  # 完了日が現在の日付より未来の日付を入れる場合はアラート
  validate :completed_date_is_invalid_if_completed_date_is_newer_than_current_date
  
  def completed_date_is_invalid_if_completed_date_is_newer_than_current_date
    errors.add(:completed_date, "は未来の日付は入れられません") if completed_date.present? && Date.parse(completed_date) > Date.current
  end

  def if_date_blank_then_today(status)
    if status == "completed"
      if self.status == "completed" && self.completed_date.blank?
        self.update_attribute(:completed_date, Date.current.strftime("%Y-%m-%d"))
      end
    elsif status == "canceled"
      if self.status == "canceled" && self.canceled_date.blank?
        self.update_attribute(:canceled_date, Date.current.strftime("%Y-%m-%d"))
      end
    end
  end
end
