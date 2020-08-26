class Lead < ApplicationRecord
  belongs_to :user
  enum status:[:in_progress, :completed, :inactive] # 案件ステータス
end
