class Step < ApplicationRecord
  belongs_to :lead
  enum status:[:not_yet, :inactive, :in_progress, :completed, :template] # 進捗ステータス
end
