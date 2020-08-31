class Lead < ApplicationRecord
  belongs_to :user
  has_many :steps, dependent: :destroy
  validates :created_date, presence: true
  validates :customer_name, presence: true
  validates :room_name, presence: true
  validates :room_num, presence: true
  validates :status, presence: true
  validates :scheduled_resident_date, presence: true
  validates :scheduled_payment_date, presence: true
  validates :notice_created, inclusion: { in: [true, false] }
  validates :notice_change_limit, inclusion: { in: [true, false] }
  validates :template, inclusion: { in: [true, false] }
  validates :template_name, presence: true, if: -> { template? }
  enum status:[:in_progress, :completed, :inactive] # 案件ステータス
end
