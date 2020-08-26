class User < ApplicationRecord
  belongs_to :company
  has_many :leads, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum status: { active: 0,
                 inactive: 1,
                 retirement: 2
               }

  validate :active_superior_in_the_same_company, on: :update

  validates :name, length: { in: 6..50 }
  validates :login_id, uniqueness: true, length: { in: 4..20 }
  validates :superior, inclusion: { in: [true, false] }
  validates :admin, inclusion: { in: [true, false] }
  validates :superior_id, presence: true
  validates :lead_count, numericality: { greater_than_or_equal_to: 0 }
  validates :lead_count_delay, numericality: { greater_than_or_equal_to: 0 }
  validates :notified_num, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :status, presence: true

  def active_superior_in_the_same_company
    unless User.find(superior_id).company_id == User.find(id).company_id &&
       User.find(superior_id).status == "active"
      errors.add(:superior_id, "に無効な人物が入力されています。")
    end
  end
end
