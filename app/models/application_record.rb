class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  scope :not_self, -> (model) { where.not(id: model.id) }
  scope :todo, -> { where(status: ["not_yet", "in_progress"]) }
  scope :not_yet, -> { where(status: "not_yet") }
  scope :inactive, -> { where(status: "inactive") }
  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }
  scope :template, -> { where(status: "template") }
  scope :canceled, -> { where(status: "canceled") }
  
  # 完了日は未来の日付禁止
  def completed_date_prohibit_future
    if self.completed_date.present?
      errors.add(:completed_date, "に未来の日付は入力できません。") if Date.parse(self.completed_date) > Date.current
    end
  end
  
end
