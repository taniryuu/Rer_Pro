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
  enum status:[:in_progress, :completed, :inactive] # 案件ステータス
  
  # 案件検索機能。
  def Lead.search(search_column, search_word)
    return Lead.all unless search_word
    Lead.where(["#{search_column} LIKE ?", "%#{search_word}%"])
  end
end
