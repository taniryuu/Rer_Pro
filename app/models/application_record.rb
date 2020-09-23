class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  # 完了日は未来の日付禁止
  def completed_date_prohibit_future
    errors.add(:completed_date, "に未来の日付は入力できません。") if Date.parse(self.completed_date) > Date.current
  end
  
end
