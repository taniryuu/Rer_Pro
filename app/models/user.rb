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

  validates :name, length: { in: 3..50 }
  validates :login_id, uniqueness: true, length: { in: 2..20 }
  validates :superior, inclusion: { in: [true, false] }
  validates :admin, inclusion: { in: [true, false] }
  validates :superior_id, presence: true, if: :start_up_create_user?
  validates :lead_count, numericality: { greater_than_or_equal_to: 0 }
  validates :lead_count_delay, numericality: { greater_than_or_equal_to: 0 }
  validates :notified_num, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :status, presence: true

  # 同じ会社のユーザー&&アクティブなstatusを持っていない時にエラー
  def active_superior_in_the_same_company
    unless User.find(superior_id).company_id == User.find(id).company_id &&
           User.find(superior_id).status == "active"
      errors.add(:superior_id, "に無効な人物が入力されています。")
    end
  end

  # 所属している企業内に他のユーザーが存在するか検証
  def start_up_create_user?
    User.where(company_id: self.company_id) == nil?
  end

  # 同じ会社内の全ユーザー一覧
  def company_of_user
    User.where(company_id: self.company_id).order(id)
  end
end
