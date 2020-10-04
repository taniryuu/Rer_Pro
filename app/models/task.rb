class Task < ApplicationRecord
  belongs_to :step
  validates :name, presence: true, length: { in: 0..60 }
  validates :memo, length: { in: 0..400 }
  validates :scheduled_complete_date, presence: true
  enum status: [:not_yet, :completed, :canceled] # 進捗ステータス
  
  # 完了日に現在の日付より未来の日付を入れる場合はアラート
  validate :not_newer_than_today

  def not_newer_than_today
    errors.add(:completed_date, "は未来の日付は入れられません") if completed_date.present? && Date.parse(completed_date) > Date.current
  end

  # 完了日または中止にした日が空なら今日の日付を入れる
  def date_blank_then_today(status)
    if status == "completed"
      if self.status == "completed" && self.completed_date.blank?
        self.update_attribute(:completed_date, (I18n.l Date.current))
      end
    elsif status == "canceled"
      if self.status == "canceled" && self.canceled_date.blank?
        self.update_attribute(:canceled_date, (I18n.l Date.current))
      end
    end
  end
end
